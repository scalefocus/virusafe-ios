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

protocol LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         for phoneNumber: String,
                         completion: @escaping SendLocationCompletion)
    // TODO: Implement Proximity API
}

class LocationRepository: LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         for phoneNumber: String,
                         completion: @escaping SendLocationCompletion) {
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"
        // ??? Pass BT id
        GpsApiRequest(location: location,
                      phoneNumber: phoneNumber,
                      timestamp: timestamp)
            .execute { (data, response, error) in
                guard let statusCode = response?.statusCode, error == nil else {
                    completion(.failure(.general))
                    return
                }

                let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

                switch statusCodeResult {
                    case .succes:
                        completion(.success(Void()))
                    case .failure:
                        // TODO: Handle too many requests
                        completion(.failure(.server))
                }
            }
    }
}
