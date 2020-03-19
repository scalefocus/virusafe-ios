//
//  HomeViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Начален екран"
    }

    @IBAction func didTapSurveyButton(_ sender: Any) {
        let surveyViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(HealthStatusViewController.self)")
        navigationController?.pushViewController(surveyViewController, animated: true)
    }
    
}
