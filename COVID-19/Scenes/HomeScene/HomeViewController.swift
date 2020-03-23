//
//  HomeViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import Pulsator

class HomeViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var animationBackgroundView: UIView!
    @IBOutlet private weak var startButton: UIButton!

    // MARK: Pulsator

    private let defaultPulses = 5
    private let radiusAdjustment: CGFloat = 36
    private let pulsator = Pulsator()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Начален екран"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        startButton.setTitle("НАЧАЛО", for: .normal)

        // Add pulsator
        startButton.layer.superlayer?.insertSublayer(pulsator, below: startButton.layer)
        // setup
        pulsator.numPulse = defaultPulses
        pulsator.fromValueForRadius = 0.4
        pulsator.keyTimeForHalfOpacity = 0
        pulsator.backgroundColor = UIColor.healthBlue?.cgColor
        animationBackgroundView.backgroundColor = .healthBlue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = startButton.layer.position
        pulsator.radius = startButton.bounds.width / 2 + radiusAdjustment
        animationBackgroundView.cornerRadius = animationBackgroundView.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        pulsator.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        pulsator.stop()
    }

    // MARK: Actions

    @IBAction private func didTapSurveyButton(_ sender: Any) {
        let surveyViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "\(HealthStatusViewController.self)")
        navigationController?.pushViewController(surveyViewController, animated: true)
    }
    
}

