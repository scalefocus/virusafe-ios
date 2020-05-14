//
//  BluetoothManager.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class BluetoothManager {

    // MARK: Singleton

    static let shared = BluetoothManager()
    private init() {
        self.advertiser = BleAdvertiser(agent: encountersManager, backgroundTask: bgTask)
        self.scanner = BleScanner(agent: encountersManager, backgroundTask: bgTask)
    }

    private lazy var bgTask = BluetoothBackgroundTask()
    private (set) lazy var encountersManager = EncountersManager()

    private var advertiser: Advertiser?
    private var scanner: Scanner?

    func bluetoothEnabledAllTime() {
        self.advertiser?.setMode(.enabledAllTime)
        self.scanner?.setMode(.enabledAllTime)
    }

    func bluetoothEnabledPartTime() {
        self.advertiser?.setMode(
            .enabledPartTime(
                advertisingOnTime: Constants.Bluetooth.AdvertisingOnTimeout,
                advertisingOffTime: Constants.Bluetooth.ScanningOffTimeout
            )
        )
        self.scanner?.setMode(
            .enabledPartTime(
                scanningOnTime: Constants.Bluetooth.AdvertisingOnTimeout,
                scanningOffTime: Constants.Bluetooth.ScanningOffTimeout
            )
        )
    }
}
