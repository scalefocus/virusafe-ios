//
//  BLEViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 31.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class BLEViewController: UIViewController {

    @IBOutlet private weak var deviceIdentifierLabel: UILabel!
    @IBOutlet private weak var detectedDevicesIdentifiersTextView: UITextView!

    private var bluetoothManager: BLEService!
    private let deviceIdentifier: String = UUID().uuidString

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bluetoothManager = BLEService(with: deviceIdentifier, delegate: self)
        deviceIdentifierLabel.text = bluetoothManager.identifier
    }

}

// MARK: BLEServiceDelegate

extension BLEViewController: BLEServiceDelegate {
    func service(_ service: BLEService, foundDevices devices: [BLEDevice]) {
        for device in devices {
            let message = "Beacon \(device.identifier) was found \(device.proximity.description) away"
            print(message)
            detectedDevicesIdentifiersTextView.text += "\(message)\r"
        }
    }

    // Note : If the user at some point changes the BT permissions, iOS will SIGKILL the app.
    // (It's not crash it's default behaviour of iOS)
    func service(_ service: BLEService, unauthorized isCentral: Bool) {
        print("BLE is not authorized")
        // TODO: Ask user to change settings
    }
}
