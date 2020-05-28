//
//  LocationRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

typealias SendLocationCompletion = ((ApiResult<Void>) -> Void)
typealias SendNearbyDevicesCompletion = ((ApiResult<Void>) -> Void)

protocol LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         completion: @escaping SendLocationCompletion)
//    func sendNearbyDevices(_ devices: [BLEDevice],
//                           latitude: Double,
//                           longitude: Double,
//                           completion: @escaping SendLocationCompletion)
}

class LocationRepository: LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         completion: @escaping SendLocationCompletion) {
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"

//        let bluetoothId = BLEBeaconIdentifierHelper.readIdentifierFromJWTToken() ?? "0"
        let bluetoothId = "0"
        // ??? Pass BT id
        GpsApiRequest(location: location,
                      timestamp: timestamp,
                      bluetoothId: bluetoothId)
            .executeWithHandling { (_, response, error) in
                guard let statusCode = response?.statusCode, error == nil else {
                    completion(.failure(.general))
                    return
                }

                let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

                switch statusCodeResult {
                case .success:
                    completion(.success(Void()))
                case .failure:
                    // This is background communication we don't care about specific errors
                    completion(.failure(.server))
                }
            }
    }

//    func sendNearbyDevices(_ devices: [BLEDevice],
//                           latitude: Double,
//                           longitude: Double,
//                           completion: @escaping SendLocationCompletion) {
//        let location = UserLocation(latitude: latitude, longitude: longitude)
//        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"
//        // !!! devices list contains only those in immediate range so hardcode the distance
//        let proximities = devices.map { Proximitiy(distance: "2", uuid: $0.identifier) }
//
//        ProximityApiRequest(location: location, nearbyDevices: proximities, timestamp: timestamp)
//            .execute { (data, response, error) in
//                guard let statusCode = response?.statusCode, error == nil else {
//                    completion(.failure(.general))
//                    return
//                }
//
//                let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)
//
//                switch statusCodeResult {
//                    case .succes:
//                        completion(.success(Void()))
//                    case .failure:
//                        // This is background communication we don't care about specific errors
//                        completion(.failure(.server))
//                }
//            }
//    }
}

// !!! We will set this token in advertising data
//final class BLEBeaconIdentifierHelper {
//    static func readIdentifierFromJWTToken() -> String? {
//        let decoder = JWTDecoder()
//        // Not registered yet
//        guard let token = TokenStore.shared.token else {
//            return nil
//        }
//        let jwtBody: [String: Any] = decoder.decode(jwtToken: token)
//        guard let userGuid = jwtBody["userGuid"] as? String else {
//            return nil
//        }
//        return userGuid
//    }
//}
