//
//  BluetoothIdentifierStore.swift
//  iPlayWithBT
//
//  Created by Aleksandar Sergeev Petrov on 6.04.20.
//  Copyright © 2020 Aleksandar Sergeev Petrov. All rights reserved.
//

import Foundation

final class BluetoothIdentifierStore {

    // MARK: Singleton

    static let shared = BluetoothIdentifierStore()
    private init() { }

    // TODO: Actual from JWT
    private func uuid() -> UUID? {
        guard let uuidString = BLEBeaconIdentifierHelper.readIdentifierFromJWTToken() else {
            return nil
        }

        return UUID(uuidString: uuidString)
    }

    func getBeaconId() -> BeaconId? {
        guard let uuid = self.uuid() else {
            return nil
        }
        let data = uuid.data
        let result = BeaconId(data: data)
        return result
    }

}
