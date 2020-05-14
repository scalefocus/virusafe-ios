//
//  ViewController.swift
//  iPlayWithBT
//
//  Created by Aleksandar Sergeev Petrov on 30.03.20.
//  Copyright © 2020 Aleksandar Sergeev Petrov. All rights reserved.
//

import UIKit

protocol EncounterView: class {
    func didAddEncounter(_ encounter: Encounter)
}

class BLEViewController: UIViewController {

    @IBOutlet private weak var deviceIdentifierLabel: UILabel!
    @IBOutlet private weak var detectedDevicesIdentifiersTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceIdentifierLabel.text = BLEBeaconIdentifierHelper.readIdentifierFromJWTToken()
        BluetoothManager.shared.encountersManager.addView(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BluetoothManager.shared.encountersManager.removeView()
    }

}

// MARK: EncounterViewType

extension BLEViewController: EncounterViewType {
    func didAddEncounter(_ encounter: Encounter) {
        let message = "Encounter \(encounter.deviceId) was found \(encounter.distance()) away"
        detectedDevicesIdentifiersTextView.text += "\(message)\r"
    }
}
