//
//  BLEBeaconIdentifierHelper.swift
//  Development
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class BLEBeaconIdentifierHelper {
    static func readIdentifierFromJWTToken() -> String? {
        let decoder = JWTDecoder()
        // Not registered yet
        guard let token = TokenStore.shared.token else {
            return nil
        }
        let jwtBody: [String: Any] = decoder.decode(jwtToken: token)
        guard let userGuid = jwtBody["userGuid"] as? String else {
            return nil
        }
        return userGuid
    }
}
