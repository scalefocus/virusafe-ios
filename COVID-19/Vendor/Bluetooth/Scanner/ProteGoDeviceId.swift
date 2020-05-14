import Foundation
import CoreBluetooth

/// Due to the iOS limitations, we can't advertsie our own manufacturer data as a peripheral.
/// On Android devices it is posssible and very useful to be able to identify devices, which
/// change their MAC addresses every established connection.
///
/// This enum provides unique device identifier covering both cases.
enum ProteGoDeviceId {
    case peripheralInstance(CBPeripheral)
    case incompleteBeaconId(Data)
    case beaconId(BeaconId)

    func hasBeaconId() -> Bool {
        switch self {
        case .peripheralInstance:
            return false
        case .incompleteBeaconId:
            return true
        case .beaconId:
            return true
        }
    }
}

extension ProteGoDeviceId: Hashable, Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case let .peripheralInstance(peripheral):
            return peripheral.identifier.uuidString
        case let .incompleteBeaconId(data):
            return data.toHexString()
        case let .beaconId(beaconId):
            return beaconId.getData().toHexString()
        }
    }

    static func == (lhs: ProteGoDeviceId, rhs: ProteGoDeviceId) -> Bool {
        switch (lhs, rhs) {
        case let (.peripheralInstance(lhp), .peripheralInstance(rhp)):
            return lhp == rhp
        case let (.incompleteBeaconId(lhd), .incompleteBeaconId(rhd)):
            return lhd.elementsEqual(rhd)
        case let (.beaconId(lhb), .beaconId(rhb)):
            return lhb == rhb
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .peripheralInstance(peripheral):
            hasher.combine(peripheral)
        case let .incompleteBeaconId(data):
            hasher.combine(data)
        case let .beaconId(beaconId):
            hasher.combine(beaconId)
        }
    }
}
