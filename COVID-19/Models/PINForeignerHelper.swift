//
//  PINForeignerHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 10.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class PINForeignerHelper {
    private let weights: [Int]  = [21, 19, 17, 13, 11, 9, 7, 3, 1]
    static let maximumPersonalNumberLength = 10

    func isValid(pin: String) -> Bool {
        guard pin.count == PINForeignerHelper.maximumPersonalNumberLength else {
            // Invalid length
            return false
        }

        guard validateChecksum(pin: pin) else {
            // bad checksum
            return false
        }

        return true
    }

    private func validateChecksum(pin: String) -> Bool {
        guard let char = pin.last else { return false }
        let checksum = Int(String(char))
        var sum: Int = 0
        for offset in 0..<9 {
            let index = pin.index(pin.startIndex, offsetBy: offset)
            sum += ((Int(String(pin[index])) ?? 0) * weights[offset])
        }
        let calculatedChecksum = sum % 10
        let result = checksum == calculatedChecksum
        return result
    }
}
