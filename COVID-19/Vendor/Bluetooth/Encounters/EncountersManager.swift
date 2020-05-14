import Foundation
import CoreLocation

// TODO: Background task
final class EncountersManager: EncountersManagerType {

    // MARK: Object lifecycle

    init() {
        startTimer()
    }

    deinit {
        stopTimer()
    }

    // MARK: Timer

    private var sendTimer: Timer?
    private var sendIntervalInSec: TimeInterval = 120

    private func stopTimer() {
        self.sendTimer?.invalidate()
        self.sendTimer = nil
    }

    private func startTimer() {
        let timer = Timer.init(timeInterval: sendIntervalInSec, repeats: true) { [weak self] _ in
            self?.sendEncountersIfNeeded()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.sendTimer = timer
    }

    // MARK: Networking

    private let locationRepository: LocationRepositoryProtocol = LocationRepository()
    // !!! Handles persist
    private let store: EncountersStore = EncountersStore()

    private func sendEncountersIfNeeded() {
        let encountersToSend = store.encounters
        guard encountersToSend.count > 0 else {
            return
        }

        let location = CLLocationManager().location
        locationRepository.sendNearbyDevices(encountersToSend,
                                             latitude: location?.coordinate.latitude ?? 0,
                                             longitude: location?.coordinate.longitude ?? 0) { [weak self] result in
                                                switch result {
                                                case .success:
                                                    self?.store.remove(encountersToSend.count)
                                                case .failure(let error):
                                                    // Silent
                                                    print("Error send proximity: \(error.localizedDescription)")
                                                }
        }
    }

    // MARK: EncountersManagerType

    // NOTE: Move somewhere else...
    var lastExpiringBeaconId: ExpiringBeaconId?

    func addNewEncounter(_ encounter: Encounter) throws {
        store.append(encounter)

        if let view = view {
            DispatchQueue.main.async {
                view.didAddEncounter(encounter)
            }
        }
    }

    // MARK: Output to EncounterView

    weak var view: EncounterViewType?

    func addView(_ view: EncounterViewType) {
        self.view = view
    }

    func removeView() {
        self.view = nil
    }

}

// MARK: BeaconIdAgent

extension EncountersManager: BeaconIdAgent {
    func getBeaconId() -> ExpiringBeaconId? {
        // Get real values
        if let beaconId = BluetoothIdentifierStore.shared.getBeaconId(), self.lastExpiringBeaconId?.isExpired() ?? true {
            let expiringBeaconId = ExpiringBeaconId(
                  beaconId: beaconId,
                  expirationDate: Date(timeIntervalSinceNow: 60 * 60)
            )
            print("Got expiring Beacon ID: \(expiringBeaconId)")
            self.lastExpiringBeaconId = expiringBeaconId
            return expiringBeaconId
        }

        return self.lastExpiringBeaconId
    }

    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?) {
        guard let rssi = rssi else {
            // !!! We don't need this
            return
        }
        let deviceId = beaconId.getData().toHexString()
        print("Synchronized Beacon ID \(deviceId), rssi: \(String(describing: rssi))")
        let encounter = Encounter(deviceId: deviceId, rssi: rssi, date: Date())
        do {
            try self.addNewEncounter(encounter)
        } catch {
            print("Error with saving new encounter \(error)")
        }
    }
}

// МАРК: Persist

public protocol FilePersistable {
    /// The item's name in the filesystem.
    static var fileName: String { get }

    /// Returns a `Data` encoded representation of the item.
    ///
    /// - Returns: `Data` representation of the item.
    func transform() -> Data
}

extension FilePersistable where Self: Any {
    static var fileName: String {
        return String(describing: Self.self)
    }
}

extension FilePersistable where Self: Codable {
    public func transform() -> Data {
        do {
            let encoded = try JSONEncoder().encode(self)
            return encoded
        } catch let error {
            fatalError("Unable to encode object: \(error)")
        }
    }
}

// !!! Thread safe
final class EncountersStore: Codable, FilePersistable {

    // MARK: Helpers

    // Concurrent synchronization queue
    private let queue = DispatchQueue(label: "com.upnetix.encounter-store.queue", attributes: .concurrent)

    private let persister: FilePersistHelper? = FilePersistHelper(folder: "com.upnetix.encounters")

    // MARK: Items

    private var elements: [Encounter] = []

    var encounters: [Encounter] {
        queue.sync { // Read
            let tuple: (store: EncountersStore?, error: Error?)? = persister?.load()
            if let elements = tuple?.store?.elements {
                self.elements = elements
            }

            if let error = tuple?.error {
                print("Load file error: \(error.localizedDescription)")
            }
        }

        return self.elements
    }

    func append(_ element: Encounter) {
        // Write with .barrier
        // This can be performed synchronously or asynchronously not to block calling thread.
        queue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.elements.append(element)
            let tuple: (url: URL?, error: Error?)? = strongSelf.persister?.persist(strongSelf)
            if let error = tuple?.error {
                print("Save file error: \(error.localizedDescription)")
            }
        }
    }

    func remove(_ count: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.elements.removeFirst(count)
            let tuple: (url: URL?, error: Error?)? = strongSelf.persister?.persist(strongSelf)
            if let error = tuple?.error {
                print("Save file error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Object lifecyle

    init() {
        // Do something
    }

    // MARK: Codable

    enum CodingKeys: CodingKey {
        case elements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        elements = try container.decode([Encounter].self, forKey: .elements)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(elements, forKey: .elements)
    }

}

//

// !!! Not thread safe
final public class FilePersistHelper {

    // MARK: Helpers

    private var destination: URL
    private let fileManager: FileManager

    // MARK: Object lifecyle

    init?(folder: String) {
        // ??? Inject it
        fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory,
                                    in: .userDomainMask)
        guard let cachesDirectoryURL = urls.first else {
            return nil
        }
        destination = cachesDirectoryURL.appendingPathComponent(folder)
        do {
            try fileManager.createDirectory(at: destination,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch {
            return nil
        }
    }

    // MARK: Save

    func persist(_ item: FilePersistable) -> (URL?, Error?) {
        var url: URL?
        var error: Error?
        do {
            let fileURL = self.destination
                .appendingPathComponent(type(of: item).fileName,
                                        isDirectory: false)
            url = try persist(data: item.transform(),
                              at: fileURL)
        } catch let persistError {
            error = persistError
        }

        return (url, error)
    }

    private func persist(data: Data, at url: URL) throws -> URL {
        try data.write(to: url, options: [.atomicWrite])
        return url
    }

    // MARK: Load

    public func load<T: FilePersistable & Codable>() -> (T?, Error?) {
        let fileURL = destination.appendingPathComponent(T.fileName,
                                                         isDirectory: false)
        var decoded: T?
        var error: Error?
        do {
            let data = try Data(contentsOf: fileURL)
            decoded = try JSONDecoder().decode(T.self, from: data)
        } catch let loadError {
            error = loadError
        }
        return (decoded, error)
    }

}
