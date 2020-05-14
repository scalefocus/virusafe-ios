//
//  Encounter.swift
//  iPlayWithBT
//
//  Created by Aleksandar Sergeev Petrov on 6.04.20.
//  Copyright © 2020 Aleksandar Sergeev Petrov. All rights reserved.
//

import Foundation

struct Encounter: Codable {
    var deviceId: String
    var rssi: Int
    var date = Date()

    func distance() -> Double {
        // !!! hard coded power value. Usually ranges between -59 to -65
        let txPower: Double = -59

        if rssi == 0 {
            return -1.0 // Unknown
        }

        let ratio: Double = Double(rssi) * 1.0 / txPower

        if ratio < 1.0 {
            let distance = pow(ratio, 10)
            return distance
        } else {
            let distance = (0.89976) * pow(ratio, 7.7095) + 0.111
            return distance
        }
    }
}
