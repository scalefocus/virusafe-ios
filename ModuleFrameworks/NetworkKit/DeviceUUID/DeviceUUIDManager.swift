//
//  DeviceUUIDManager.swift
//  UniperEnergy
//
//  Created by Radoslav Radev on 15.01.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import UIKit.UIDevice

public class DeviceUUIDManager {

    public var deviceUUID: String? {
        return getUUID()
    }

    private let keychainAccess = KeychainAccess()
    private let bundleIdentifier = Bundle.main.bundleIdentifier

    // Singleton defaults
    public static let shared = DeviceUUIDManager()
    init() {}

    private func getUUID() -> String? {
        guard let bundleIdentifier = bundleIdentifier else { return nil }

        if let uuid = try? keychainAccess.queryKeychainData(itemKey: bundleIdentifier),
            !uuid.isEmpty {
            return uuid
        }

        if let newUUID = UIDevice.current.identifierForVendor?.uuidString {
            try? keychainAccess.addKeychainData(itemKey: newUUID, itemValue: bundleIdentifier)
            return newUUID
        }

        return nil
    }

}
