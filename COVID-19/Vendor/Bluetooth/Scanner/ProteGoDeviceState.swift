import Foundation
import CoreBluetooth

/// This enum describes connection flow of the device. All steps
/// are executed in sequence specified below.
enum ProteGoDeviceState {
    /// Device is closed and should no longer be used. It can be closed due to
    /// maxium allowed connection attempts.
    case closed
    /// Device is ready to be synchronized.
    case idle
    /// Device is queued for synchronization.
    case queued(CBPeripheral)
    /// Device is actively connecting to underlying device.
    case connecting(CBPeripheral)
    /// Device just connected to underlying device.
    case connected(CBPeripheral)
    /// Device is discovering ProteGO services.
    case discoveringService(CBPeripheral)
    /// Device just discovered ProteGo service.
    case discoveredService(CBService)
    /// Device is discovering ProteGO characteristic
    case discoveringCharacteristic(CBService)
    /// Device discovered ProteGo characteristic
    case discoveredCharacteristic(CBCharacteristic)
    /// Device is reading Beacon ID
    case readingBeaconId(CBCharacteristic)
    /// Device succesfully synchronized Beacon ID.
    case synchronizedBeaconId(CBCharacteristic, BeaconId)
    /// Scanner is writing it's own Beacon ID to connected device.
    case writingBeaconId(CBCharacteristic, BeaconId)
    /// Synchronization finished. If Beacon ID is specified, synchronization was
    /// successful.
    case synchronizationFinished(BeaconId?)

    /// Checks if device is in idle state.
    /// - Returns: True if device is idle.
    func isIdle() -> Bool {
        if case .idle = self {
            return true
        }
        return false
    }

    /// Check if device was in a phase which succesfully retrieved Beacon ID.
    /// - Returns: Synchronized Beacon ID if available.
    func getSynchronizedBeaconId() -> BeaconId? {
        switch self {
        case let .synchronizedBeaconId(_, beaconId):
            return beaconId
        case let .writingBeaconId(_, beaconId):
            return beaconId
        case let .synchronizationFinished(beaconId):
            return beaconId
        default:
            return nil
        }
    }

    /// Handle an event a do a state transition with side effects.
    /// - Parameter event: Triggered event
    /// - Returns: New device state and list of side effects.
    //swiftlint:disable function_body_length
    //swiftlint:disable:next cyclomatic_complexity
    func handleEvent(_ event: ProteGoDeviceEvent) -> (ProteGoDeviceState, [ProteGoDeviceEffect]) {
        switch (self, event) {

        // Ignore events in idle state
        case (.idle, _):
            return (self, [])

        // Ignore events in closed state
        case (.closed, _):
            return (self, [])

        // When queued, we connect to peripheral
        case let (.queued(peripheral), _):
            return (.connecting(peripheral), [.connect(peripheral)])

        // When connecting wait for connected event and start discovery
        case let (.connecting, .connected(peripheral)):
            return (.discoveringService(peripheral), [.discoverServices(peripheral)])

        // When connected, start discovery.
        case let (.connected(peripheral), _):
            return (.discoveringService(peripheral), [.discoverServices(peripheral)])

        // When discovering services, wait for a service
        case let (.discoveringService(peripheral), .discoveredServices(error)):
            // On error, just disconnect.
            guard error == nil else {
                return (.synchronizationFinished(nil), [])
            }
            // If found ProteGO service, continue...
            let proteGOService = peripheral.services?.first { $0.uuid == Constants.Bluetooth.ProteGOServiceUUID }
            if let proteGOService = proteGOService {
                return (.discoveringCharacteristic(proteGOService), [.discoverCharacteristics(proteGOService)])
            }
            // Wait for service modification...
            return (self, [])

        // When discovered services, continue with discovering characteristic.
        case let (.discoveredService(service), _):
            return (.discoveringCharacteristic(service), [.discoverCharacteristics(service)])

        // When discovering characteristics, wait for discovered event.
        case let (.discoveringCharacteristic, .discoveredCharacteristics(service, error)):
            // On error, just disconnect
            guard error == nil else {
                return (.synchronizationFinished(nil), [])
            }

            // If found characteristic, continue
            let proteGOCharacteristic = service.characteristics?.first {
                $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
            }
            if let proteGOCharacteristic = proteGOCharacteristic {
                return (.readingBeaconId(proteGOCharacteristic),
                        [.readValue(proteGOCharacteristic),
                         .readRSSI(proteGOCharacteristic.service.peripheral)])
            }

            // Wait for service modification...
            return (self, [])

        // When discovered characteristic, read BeaconID.
        case let (.discoveredCharacteristic(characteristic), _):
            return (.readingBeaconId(characteristic),
                    [.readValue(characteristic),
                     .readRSSI(characteristic.service.peripheral)])

        // When reading characteristic, wait for value.
        case let (.readingBeaconId, .readValue(characteristic, error)):
            // On error, disconnect.
            guard error == nil else {
                return (.synchronizationFinished(nil), [])
            }

            // If value was read properly, continue. Data will be actually synchronized
            // when device finishes whole synchronization procedure or when it's aborted.
            if let data = characteristic.value, let beaconId = BeaconId(data: data) {
                return (.writingBeaconId(characteristic, beaconId), [.writeValue(characteristic)])
            }

            // We encountered an error, disconnect.
            return (.synchronizationFinished(nil), [])

        // If synchronized value, let's try writing our own Beacon ID.
        case let (.synchronizedBeaconId(characteristic, beaconId), _):
            return (.writingBeaconId(characteristic, beaconId), [.writeValue(characteristic)])

        // If writing Beacon ID, wait for confirmation.
        case let (.writingBeaconId(_, beaconId), .wroteValue):
            // Regardless of a result finish synchronization
            return (.synchronizationFinished(beaconId), [])

        // In case of disconnection, finish synchronization.
        case (_, .disconnected):
            return (.synchronizationFinished(self.getSynchronizedBeaconId()), [])

        // Ignore other cases
        default:
            return (self, [])
        }
    }
    //swiftlint:enable function_body_length
}

extension ProteGoDeviceState: CustomStringConvertible {
    var description: String {
        switch self {
        case .closed:
            return "Closed"
        case .idle:
            return "Idle"
        case .queued:
            return "Queued"
        case .connecting:
            return "Connecting(..)"
        case .connected:
            return "Connected(..)"
        case .discoveringService:
            return "DiscoveringService(..)"
        case .discoveredService:
            return "DiscoveredService(..)"
        case .discoveringCharacteristic:
            return "DiscoveringCharacteristic(..)"
        case .discoveredCharacteristic:
            return "DiscoveredCharacteristic(..)"
        case .readingBeaconId:
            return "ReadingBeaconId(..)"
        case let .synchronizedBeaconId(_, beaconId):
            return "SynchronizedBeaconId(_, \(beaconId))"
        case let .writingBeaconId(_, beaconId):
            return "WritingBeaconId(_, \(beaconId))"
        case let .synchronizationFinished(beaconId):
            return "SynchronizationFinished(\(String(describing: beaconId)))"
        }
    }
}
