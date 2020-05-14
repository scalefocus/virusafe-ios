import Foundation
import CoreBluetooth

enum Constants {
    enum Bluetooth {
        /// Bluetooth peripheral restoration ID.
        static let BluetoothPeripheralManagerRestorationID = "com.scalefocus.bt.PeripheralManager"
        /// Bluetooth central manager restoration ID.
        static let BluetoothCentralManagerRestorationID = "com.scalefocus.bt.CentralManager"

        /// Bluetooth background task ID.
        static let BackgroundTaskID = "com.scalefocus.bt.BluetoothBackgroundTask"
        /// Bluetooth background task earliest start time
        static let BackgroundTaskEarliestBeginDate: TimeInterval = 15 * 60
        /// Bluetooth advertising task ID
        static let AdvertisingBackgroundTaskID = "bluetooth.advertiser"
        /// Bluetooth scanning task ID
        static let ScanningBackgroundTaskID = "bluetooth.scanning"

        /// Polidea's company ID used in the advertisement data.
        static let PolideaCompanyId = 0x08AF
        /// Manufacturer data version indicating that payload has ProteGO format: 16 byte Beacon ID.
        static let PolideaProteGOManufacturerDataVersion = 0x00

        /// ProteGO Service contained in GATT
        static let ProteGOServiceUUIDString = "2415" // "FD6E"// "d3cd8565-e741-4941-950a-81042aee3ef0"
        static let ProteGOServiceUUID = CBUUID(string: ProteGOServiceUUIDString)

        /// ProteGO Characteristic contained in GATT
        static let ProteGOCharacteristicUUIDString = "b5265acc-4fae-4854-a5aa-e22561fcd423"
        static let ProteGOCharacteristicUUID = CBUUID(string: ProteGOCharacteristicUUIDString)

        /// Time after which we check if connections health
        static let PeripheralSynchronizationCheckInSec: TimeInterval = 5

        /// Synchronization timeout for a peripheral in seconds. Defines how long we should wait for established connection,
        /// discovery and reading value before we decide to cancel our attempt.
        static let PeripheralSynchronizationTimeoutInSec: TimeInterval = 15

        /// Peripheral ignored timeout in seconds. Defines how long we want to restrict connection attempts to this
        /// device when synchronization was already completed.
        static let PeripheralIgnoredTimeoutInSec: TimeInterval = 60

        /// Maxium number of concurrent connections established by a peripheral manager.
        static let PeripheralMaxConcurrentConnections = 3

        /// Maximum number of connection retries before we decide to remove device until discovered once again.
        static let PeripheralMaxConnectionRetries = 3

        /// Advertising enabled period (used only in background mode)
        static let AdvertisingOnTimeout: TimeInterval = 15

        /// Advertising disabled period (used only in background mode)
        static let AdvertisingOffTimeout: TimeInterval = 45

        /// Scanning enabled period (used only in background mode)
        static let ScanningOnTimeout: TimeInterval = 15

        /// Scanning disabled period (used only in background mode)
        static let ScanningOffTimeout: TimeInterval = 45
    }
}
