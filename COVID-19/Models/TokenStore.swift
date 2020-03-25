//
//  TokenStore.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import KeychainSwift

final class TokenStore {

    // MARK: Singleton

    static var shared: TokenStore = TokenStore()
    private init() { }

    // MARK: Helper

    private let keychain = KeychainSwift()

    // MARK: Tokent

    var token: String? {
        get {
            return keychain.get("jwt")
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: "jwt")
            } else {
                keychain.delete("jwt")
            }
        }
    }

}
