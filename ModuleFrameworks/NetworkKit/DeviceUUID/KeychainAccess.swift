//
//  KeychainAccess.swift
//  UniperEnergy
//
//  Created by Radoslav Radev on 15.01.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation

class KeychainAccess {

    func addKeychainData(itemKey: String, itemValue: String) throws {
        guard let valueData = itemKey.data(using: .utf8) else {
            debugPrint("Keychain: Unable to store data, invalid input - key: \(itemKey), value: \(itemValue)")
            return
        }

        //delete old value if stored first
        do {
            try deleteKeychainData(itemKey: itemKey)
        } catch {
            debugPrint("Keychain: nothing to delete...")
        }

        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemValue as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)

        if resultCode != 0 {
            debugPrint("Keychain: value not added - Error: \(resultCode)")
        } else {
            debugPrint("Keychain: value added successfully")
        }
    }

    func deleteKeychainData(itemKey: String) throws {
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject
        ]

        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)

        if resultCodeDelete != 0 {
            debugPrint("Keychain: unable to delete from keychain: \(resultCodeDelete)")
        } else {
            debugPrint("Keychain: successfully deleted item")
        }
    }

    func queryKeychainData (itemKey: String) throws -> String? {
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }

        if resultCodeLoad != 0 {
            debugPrint("Keychain: unable to load data - \(resultCodeLoad)")
            return nil
        }

        guard let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as String? else {
            debugPrint("Keychain: error parsing keychain result - \(resultCodeLoad)")
            return nil
        }
        return keyValue
    }
}
