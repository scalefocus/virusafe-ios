import Foundation
import CoreBluetooth

/// Device events emitted by scanner, peripheral or central manager.
enum ProteGoDeviceEvent {
    /// This event starts a synchronization. If synchronization is currently in progress
    /// it will be cancelled beforehand.
    case synchronizationStarted
    /// Cancel synchronization. First argument decides if only devices which timed out
    /// should be cancelled.
    case synchronizationCancelled(Bool)
    /// Underlying peripheral connected.
    case connected(CBPeripheral)
    /// Underlying peripheral disconnected. If error is  not `nil` that means that
    /// device disconnected from us.
    case disconnected(CBPeripheral, Error?)
    /// Underlying peripheral updated RSSI value.
    case readRSSI(CBPeripheral, Int)
    /// Underlying peripheral discovered services possibly containing ProteGo services.
    case discoveredServices(Error?)
    /// Underlying peripheral discovered characteristics. Provided service is a ProteGO service.
    case discoveredCharacteristics(CBService, Error?)
    /// Underlying peripheral read value from ProteGO characteristic.
    case readValue(CBCharacteristic, Error?)
    /// Underlying peripheral wrote value to ProteGO characteristic.
    case wroteValue(CBCharacteristic, Error?)
}

extension ProteGoDeviceEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .synchronizationStarted:
            return "SynchronizationStarted"
        case let .synchronizationCancelled(onlyOnTimeout):
            return "SynchronizationCancelled(\(onlyOnTimeout))"
        case let .connected(peripheral):
            return "Connected(\(peripheral.identifier))"
        case let .disconnected(peripheral, error):
            return "Disconnected(\(peripheral.identifier), \(error.debugDescription))"
        case let .readRSSI(peripheral, rssi):
            return "ReadRSSI(\(peripheral.identifier), \(rssi))"
        case let .discoveredServices(error):
            return "DiscoveredServices(\(error.debugDescription))"
        case let .discoveredCharacteristics(service, error):
            return "DiscoveredCharacteristics(\(service.peripheral.identifier), \(error.debugDescription))"
        case let .readValue(characteristic, error):
            return "ReadValue(\(characteristic.service.peripheral.identifier), \(error.debugDescription))"
        case let .wroteValue(characteristic, error):
            return "WroteValue(\(characteristic.service.peripheral.identifier), \(error.debugDescription))"
        }
    }
}
