import Foundation

/// Class implementing this protocol is responsible for giving out Beacon IDs and
/// receiving them and storing locally.
protocol BeaconIdAgent: AnyObject {

    /// This function should return valid Beacon ID with its expiration date
    /// which will be exchanged between devices. Can return `nil` if there
    /// are are no valid Beacon IDs available.
    func getBeaconId() -> ExpiringBeaconId?

    /// This function should return service beaconId if Can return `nil` if
    /// user is not logged in and we dont have JWT token
//    func getBeaconId() -> BeaconId?

    /// This function is called when new Beacon ID is synchronized.
    ///
    /// - Parameters:
    ///   - beaconId: Synchronized Beacon ID
    ///   - rssi: RSSI value for a Beacon ID
    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?)
}
