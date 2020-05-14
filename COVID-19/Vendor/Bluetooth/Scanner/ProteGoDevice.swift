import Foundation
import CoreBluetooth

/// This class provides information about the device which was discovered by
/// a central manager. Only device ID is a stable value.
class ProteGoDevice {
    /// Unique device identfier
    private let id: ProteGoDeviceId
    /// Handle to current CBPeripheral
    private var peripheral: CBPeripheral
    /// Last discovered device. There is a chance that device with the same ID was
    /// discovered with different mac address, while current connection is in progress.
    /// Make sure to remember the handle for later use.
    private var lastDiscoveredPeripheral: CBPeripheral?
    /// Last successful synchronization date if specified. We use that value to block
    /// further connection attempts.
    private var lastSynchronizationDate: Date?
    /// Last succesful synchronized discovery date. When device is discovered with Beacon ID
    /// we remember the attempt to limit number of encounters.
    private var lastSynchronizedDiscoveryDate: Date?
    /// Last connection attempt date if specified. It is used to cancel connections to devices
    /// which don't manage to finish synchronization procedure in time.
    private var lastConnectionDate: Date?
    /// Number of connection retries, exceeding certain value will mark this device as lost.
    private var connectionRetries = 0
    /// Last RSSI value
    private var lastRSSI: Int?
    /// Current synchronization state
    private var state: ProteGoDeviceState = .idle

    init(id: ProteGoDeviceId, peripheral: CBPeripheral) {
        self.id = id
        self.peripheral = peripheral
    }

    /// Returns this instance's ID.
    /// - Returns: Device ID.
    func getId() -> ProteGoDeviceId {
        self.id
    }

    /// Returns last discovered or read RSSI value.
    /// - Returns: RSSI value.
    func getLastRSSI() -> Int? {
        self.lastRSSI
    }

    /// Check if device is Idle
    /// - Returns: True if device is idle.
    func isIdle() -> Bool {
        self.state.isIdle()
    }

    /// Update peripheral instance in next connection attempt. This is useful when peripheral
    /// instance is advertising with the same Beacon ID, suggesting it's the same device.
    /// - Parameter peripheral: New peripheral instance.
    /// - Returns: Old peripheral instance to close.
    func updateDeviceWith(peripheral: CBPeripheral) -> CBPeripheral? {
        // No need to update if peripheral is the same.
        guard peripheral != self.peripheral else {
            return nil
        }

        // If last peripheral is the same as a new one, ignore
        if let lastPeripheral = self.lastDiscoveredPeripheral, lastPeripheral == peripheral {
            return nil
        }

        // Update peripheral
        let closedPeripheral = self.lastDiscoveredPeripheral
        self.lastDiscoveredPeripheral = peripheral
        return closedPeripheral
    }

    /// Update RSSI of a device. If device is advertising with proper Beacon ID and
    /// we are ready to synchronize return Beacon ID to suggest synchronization.
    /// - Parameter rssi: Device RSSI
    /// - Returns: Beacon ID instance if we are ready to synchronize.
    func updateRSSI(rssi: Int?) -> BeaconId? {
        self.lastRSSI = rssi

        guard case let .beaconId(beaconId) = self.id else {
            return nil
        }

        let now = Date()
        let syncTimeout = Constants.Bluetooth.PeripheralIgnoredTimeoutInSec
        let lastSyncDate = self.lastSynchronizedDiscoveryDate ?? Date(timeIntervalSince1970: 0)
        if lastSyncDate.addingTimeInterval(syncTimeout) < now {
            self.lastSynchronizedDiscoveryDate = now
            return beaconId
        }

        return nil
    }

    /// Returns true if specified peripheral instance is currently in use.
    /// - Parameter peripheral: Peripheral instance
    /// - Returns: True if currently in use.
    func isPeripheralActive(peripheral: CBPeripheral) -> Bool {
        return self.peripheral == peripheral
    }

    /// Defines if peripheral is ready to connect.
    func isReadyToConnect() -> Bool {
        // Make sure that we are in idle state
        guard self.state.isIdle() else {
            return false
        }

        // If there were connection attempts to this device, wait for a
        // time when we can connect.
        if let lastConnectionDate = self.lastConnectionDate, self.connectionRetries != 0 {
            let nextReconnectionTime = lastConnectionDate.addingTimeInterval(
                Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec
            )
            if nextReconnectionTime > Date() {
                return false
            }
        }

        // If we never synced with this device, let's do it.
        guard let lastSyncDate = self.lastSynchronizationDate else {
            return true
        }

        // Check if we are ready for the next connection attempt.
        let ignoreTimeout = Constants.Bluetooth.PeripheralIgnoredTimeoutInSec
        return lastSyncDate.addingTimeInterval(ignoreTimeout) < Date()
    }

    /// Function specifies if this device has higher priority in the next connection attempt.
    /// - Parameter other: Other device's state
    func hasHigherPriorityForConnection(other: ProteGoDevice) -> Bool {
        // We check in following order (from most important to less important):

        // Current connection state
        let idle = self.state.isIdle()
        let otherIdle = other.state.isIdle()
        guard idle == otherIdle else {
            // Idle peripheral has higher priority
            return idle
        }

        // Device type. Devices with BeaconId are more prone to be lost quickly.
        guard self.id.hasBeaconId() == other.id.hasBeaconId() else {
            // Having Beacon ID gives priority.
            return self.id.hasBeaconId()
        }

        // Connection retries
        guard connectionRetries == other.connectionRetries else {
            // If we have lower number of connection retries, we have higher priority.
            return connectionRetries < other.connectionRetries
        }

        // Last synchronization time
        let syncTime = self.lastSynchronizationDate?.timeIntervalSince1970 ?? 0
        let otherSyncTime = other.lastSynchronizationDate?.timeIntervalSince1970 ?? 0
        guard syncTime == otherSyncTime else {
            // If our sync time is older, we have got priority.
            return syncTime < otherSyncTime
        }

        // RSSI
        let RSSI = self.lastRSSI ?? Int.min
        let otherRSSI = other.lastRSSI ?? Int.min

        // Higher value means better signal.
        return RSSI >= otherRSSI
    }

    /// Handle incoming events from central, peripheral or scanner.
    /// - Parameter event: Event to handle.
    /// - Returns: Effects to execute.
    func handle(event: ProteGoDeviceEvent) -> [ProteGoDeviceEffect] {
        var effects: [ProteGoDeviceEffect] = []

        if case let .readRSSI(_, rssi) = event {
            self.lastRSSI = rssi
        }

        if case .synchronizationStarted = event {
            effects.append(contentsOf: self.startSynchronization())
        }

        if case let .synchronizationCancelled(onlyOnTimeout) = event {
            var cancel = !onlyOnTimeout
            if let date = self.lastConnectionDate, onlyOnTimeout {
                let syncTimeout = Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec
                if date.addingTimeInterval(syncTimeout) < Date() {
                    cancel = true
                }
            }
            if !cancel {
                return []
            }

            effects.append(contentsOf: self.stopSynchronization(forceRemoval: !onlyOnTimeout))
        }

        // Synchronize state with periphera's state.
        synchronizeWithPeripheralState()

        // Handle events based on state value
        let (newState, newEffects) = self.state.handleEvent(event)
        self.state = newState
        effects.append(contentsOf: newEffects)

        // Check if synchronization is finished.
        if case .synchronizationFinished = self.state {
            effects.append(contentsOf: self.stopSynchronization(forceRemoval: false))
        }

        return effects
    }

    /// Starts new synchronization
    /// - Returns: Effects to execute.
    private func startSynchronization() -> [ProteGoDeviceEffect] {
        var effects: [ProteGoDeviceEffect] = []

        // Make sure to stop previous synchronization
        effects.append(contentsOf: self.stopSynchronization(forceRemoval: false))
        if case .closed = self.state {
            // Don't start synchronization on already closed device
            return effects
        }

        // Reset state to initial value
        self.state = .queued(self.peripheral)
        self.lastConnectionDate = Date()

        // Check if we received new peripheral, close old one
        // and start using a new one.
        if let newPeripheral = self.lastDiscoveredPeripheral, newPeripheral != peripheral {
            effects.append(.close(self.peripheral))
            self.peripheral = newPeripheral
            self.lastDiscoveredPeripheral = nil
        }

        return effects
    }

    /// Stop synchronization and check if previous attempt was succesfull
    /// - Parameter forceRemoval: True if device should be immidiately removed.
    /// - Returns: Effects to execute
    private func stopSynchronization(forceRemoval: Bool) -> [ProteGoDeviceEffect] {
        var effects: [ProteGoDeviceEffect] = []
        var previousSyncFinished = false

        // If not in idle state, disconnect
        if !self.state.isIdle() {
            effects.append(.disconnect(peripheral))
        }

        // Check if we had valid synchronization.
        if let beaconId = self.state.getSynchronizedBeaconId() {
            effects.append(.synchronizeBeaconId(beaconId))
            previousSyncFinished = true
        }

        // Remove if needed.
        if forceRemoval {
            effects.append(.close(self.peripheral))
            effects.append(.remove)
            return effects
        }

        // Check connection retries to decide if we should
        // close the device.
        if previousSyncFinished || self.state.isIdle() {
            self.state = .idle
            if previousSyncFinished {
                self.lastSynchronizationDate = Date()
                self.connectionRetries = 0
            }
        } else {
            let maxConnectionRetries =
                self.id.hasBeaconId() ? 0 : Constants.Bluetooth.PeripheralMaxConnectionRetries
            if self.connectionRetries >= maxConnectionRetries {
                self.state = .closed
                effects.append(.close(self.peripheral))
                effects.append(.remove)
            } else {
                self.connectionRetries += 1
                self.state = .idle
            }
        }

        return effects
    }

    private func synchronizeWithPeripheralState() {
        // Get information about the peripheral
        let peripheral = self.peripheral
        let connected = self.peripheral.state == .connected
        let discoveredService = peripheral.services?.first {
            $0.uuid == Constants.Bluetooth.ProteGOServiceUUID
        }
        let discoveredCharacteristic = discoveredService?.characteristics?.first {
            $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
        }

        // Check if we are already connected.
        if case .queued = self.state, connected {
            self.state = .connected(peripheral)
        }
        if case .connecting = self.state, connected {
            self.state = .connected(peripheral)
        }

        // Check if we have service
        if case .connected = self.state, let service = discoveredService {
            self.state = .discoveredService(service)
        }
        if case .discoveringService = self.state, let service = discoveredService {
            self.state = .discoveredService(service)
        }

        // Check if we have characteristic
        if case .discoveredService = self.state, let characteristic = discoveredCharacteristic {
            self.state = .discoveredCharacteristic(characteristic)
        }
        if case .discoveringCharacteristic = self.state, let characteristic = discoveredCharacteristic {
            self.state = .discoveredCharacteristic(characteristic)
        }
    }
}

extension ProteGoDevice: CustomStringConvertible {
    var description: String {
        let now = Date()
        var nextSyncTime = 0.0
        if let lastSync = self.lastSynchronizationDate {
            let nextSync = lastSync.addingTimeInterval(
                Constants.Bluetooth.PeripheralIgnoredTimeoutInSec
            )
            nextSyncTime = nextSync.timeIntervalSince1970 - now.timeIntervalSince1970
        }
        return "[id=\(id), state=\(state), retries=\(connectionRetries), nextSync=\(Int(nextSyncTime)) s]"
    }
}
