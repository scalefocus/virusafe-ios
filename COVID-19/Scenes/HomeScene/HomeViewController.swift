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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tncButton: UIButton!

    // MARK: Pulsator

    private let defaultPulses = 5
    private let radiusAdjustment: CGFloat = 36
    private let minValueForRadius: Float = 0.4
    private let pulsator = Pulsator()

    private func setupPulsatorLayer() {
        pulsator.numPulse = defaultPulses
        pulsator.fromValueForRadius = minValueForRadius
        pulsator.backgroundColor = UIColor.healthBlue?.cgColor
        animationBackgroundView.backgroundColor = .healthBlue
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        // add pulse animation behind the button
        startButton.layer.superlayer?.insertSublayer(pulsator, below: startButton.layer)
        setupPulsatorLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = startButton.layer.position
        pulsator.radius = startButton.bounds.width / 2 + radiusAdjustment
        animationBackgroundView.cornerRadius =
            animationBackgroundView.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        pulsator.start()
        
        askForPushNotifications()
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

    @IBAction private func tncButtonTap() {
        guard let tncViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "\(TermsAndConditionsViewController.self)")
            as? TermsAndConditionsViewController else {
                assertionFailure("TermsAndConditionsViewController is not found")
                return
        }
        tncViewController.viewModel = TermsAndConditionsViewModel(isAcceptButtonVisible: false)
        tncViewController.userResponseHandler = { [weak self] _ in
            self?.navigationController?.popViewController(animated: false)
        }
        navigationController?.pushViewController(tncViewController, animated: true)
    }

    // MARK: Setup UI

    private func localize() {
        title = "Начален екран"
        titleLabel.text = "Въведете вашите симптоми"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        startButton.setTitle("НАЧАЛО", for: .normal)
        tncButton.setTitle("Условия за ползване", for: .normal)
    }
    
    
    private func askForPushNotifications() {
        if #available(iOS 10.0, *) {
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
    
}
