import Foundation
import CoreBluetooth

/// Device effect to execute by the scanner.
enum ProteGoDeviceEffect {
    /// Remove current device from the list of known devices as we
    /// reached a limit of allowed connection attemps.
    case remove
    /// Close underlying peripheral as it's no longer used.
    case close(CBPeripheral)
    /// Connect to underlying peripheral.
    case connect(CBPeripheral)
    /// Disconnect from peripheral as connection is no longer needed.
    case disconnect(CBPeripheral)
    /// Discover ProteGO services of the underlying peripheral.
    case discoverServices(CBPeripheral)
    /// Discover ProteGO characteristic(s) of the underlying service.
    case discoverCharacteristics(CBService)
    /// Read ProteGO characteristic value.
    case readValue(CBCharacteristic)
    /// Write ProteGO characteristic value.
    case writeValue(CBCharacteristic)
    /// Read RSSI of the device.
    case readRSSI(CBPeripheral)
    /// Beacon ID was fetched from device. Let's synchronize it.
    case synchronizeBeaconId(BeaconId)
}

extension ProteGoDeviceEffect: CustomStringConvertible {
    var description: String {
        switch self {
        case .remove:
            return "Remove"
        case let .close(peripheral):
            return "Close(\(peripheral.identifier))"
        case let .connect(peripheral):
            return "Connect(\(peripheral.identifier))"
        case let .disconnect(peripheral):
            return "Disconnect(\(peripheral.identifier))"
        case let .discoverServices(peripheral):
            return "DiscoverServices(\(peripheral.identifier))"
        case let .discoverCharacteristics(service):
            return "DiscoverCharacteristics(\(service.peripheral.identifier))"
        case let .readValue(characteristic):
            return "ReadValue(\(characteristic.service.peripheral.identifier))"
        case let .writeValue(characteristic):
            return "WriteValue(\(characteristic.service.peripheral.identifier))"
        case let .readRSSI(peripheral):
            return "ReadRSSI(\(peripheral.identifier))"
        case let .synchronizeBeaconId(beaconId):
            return "SynchronizeBeaconId(\(beaconId))"
        }
    }
}
