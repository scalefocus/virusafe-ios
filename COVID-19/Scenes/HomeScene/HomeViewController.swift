//
//  HomeViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var targetUUID: UILabel!
    @IBOutlet weak var myUUID: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Начален екран"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        INBeaconService.singleton()?.add(self)
        INBeaconService.singleton()?.startDetecting()
        INBeaconService.singleton()?.startBroadcasting()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func didTapSurveyButton(_ sender: Any) {
        let surveyViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(HealthStatusViewController.self)")
        navigationController?.pushViewController(surveyViewController, animated: true)
    }
    
}

extension HomeViewController: INBeaconServiceDelegate {
    func service(_ service: INBeaconService!, foundDeviceUUID uuid: String!, with range: INDetectorRange) {
        
        targetUUID.text = uuid
        myUUID.text = UIDevice.current.identifierForVendor!.uuidString
        switch range {
        case INDetectorRangeImmediate:
            distanceLabel.text = "Within 1ft"
        case INDetectorRangeNear:
            distanceLabel.text = "Within 5ft"
        case INDetectorRangeFar:
            distanceLabel.text = "Within 60ft"
        default:
            distanceLabel.text = "Out of range"
            targetUUID.text = ""
        }
    }
}

