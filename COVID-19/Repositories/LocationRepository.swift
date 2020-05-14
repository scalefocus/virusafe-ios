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
    func sendNearbyDevices(_ devices: [Encounter],
                           latitude: Double,
                           longitude: Double,
                           completion: @escaping SendLocationCompletion)
}

class LocationRepository: LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         completion: @escaping SendLocationCompletion) {
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"

        // !!! Don't get confused by the name.
        // This is actually internal identifier to link user with location and proximity data
        let bluetoothId = BLEBeaconIdentifierHelper.readIdentifierFromJWTToken() ?? "0"
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

    func sendNearbyDevices(_ devices: [Encounter],
                           latitude: Double,
                           longitude: Double,
                           completion: @escaping SendLocationCompletion) {
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"
        // ??? filter devices list to contain only those in immediate range so hardcode the distance
        let proximities = devices.map {
            Proximitiy(distance: String(format: "%.1f", $0.distance()), uuid: $0.deviceId)
        }

        ProximityApiRequest(location: location, nearbyDevices: proximities, timestamp: timestamp)
            .execute { (_, response, error) in
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
}
