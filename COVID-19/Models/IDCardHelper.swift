//
//  IDCardHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 10.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

// MARK: ID Card or Passport

final class IDCardHelper {
    static let minimumPersonalNumberLength = 5
    static let maximumPersonalNumberLength = 20

    let pattern = "^[a-zA-Z0-9]{5,20}$"

    func isValid(id: String) -> Bool {
        if id.count < IDCardHelper.minimumPersonalNumberLength || id.count > IDCardHelper.maximumPersonalNumberLength {
            return false
        }

        let predicate = NSPredicate(format: "self MATCHES [c] %@", pattern)
        let result = predicate.evaluate(with: id)
        return result
    }
}
