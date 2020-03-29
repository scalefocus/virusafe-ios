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
            if UserDefaults.standard.bool(forKey: "isUserRegistered") {
                return keychain.get("jwt")
            } else {
                // app deleted
                keychain.delete("jwt") // in case
                return nil
            }
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(true, forKey: "isUserRegistered")
                keychain.set(token, forKey: "jwt")
            } else {
                UserDefaults.standard.removeObject(forKey: "isUserRegistered")
                keychain.delete("jwt")
            }
            UserDefaults.standard.synchronize()
        }
    }

}
