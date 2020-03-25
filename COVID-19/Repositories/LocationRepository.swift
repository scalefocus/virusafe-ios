//
//  LocationRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

protocol LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         for phoneNumber: String,
                         completion: @escaping (() -> Void))
    // TODO: Implement Proximity API
}

class LocationRepository: LocationRepositoryProtocol {
    func sendGPSLocation(latitude: Double,
                         longitude: Double,
                         for phoneNumber: String,
                         completion: @escaping (() -> Void)) {
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        // ??? Pass BT id
        GpsApiRequest(location: location,
                      phoneNumber: phoneNumber,
                      timestamp: timestamp)
            .execute { (_, _, _) in
                completion()
            }
    }
}
