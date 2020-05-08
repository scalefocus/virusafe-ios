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
                let token = keychain.get("jwt")
                if !UserDefaults.standard.bool(forKey: "migrated") && UserDefaults.standard.bool(forKey: "launched_before") {
                    UserDefaults.standard.set(true, forKey: "migrated")
                    if let token  = token {
                        keychain.set(token, forKey: "jwt", withAccess: .accessibleAfterFirstUnlock)
                    }
                }
                return token
            } else {
                // app deleted
                keychain.delete("jwt") // in case
                return nil
            }
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(true, forKey: "isUserRegistered")
                keychain.set(token, forKey: "jwt", withAccess: .accessibleAfterFirstUnlock)
            } else {
                UserDefaults.standard.removeObject(forKey: "isUserRegistered")
                keychain.delete("jwt")
            }
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: RefreshToken

    var refreshToken: String? {
        get {
            return keychain.get("refreshToken")
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: "refreshToken", withAccess: .accessibleAfterFirstUnlock)
            } else {
                keychain.delete("refreshToken")
            }
        }
    }

}
