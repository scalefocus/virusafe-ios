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
    @IBOutlet private weak var moreInfoButton: UIButton!

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
        moreInfoButton.borderColor = .healthBlue ?? .black
        // add pulse animation behind the button
        startButton.layer.superlayer?.insertSublayer(pulsator, below: startButton.layer)
        setupPulsatorLayer()
        
        askForPushNotifications()
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

    @IBAction private func moreInfoDidTap() {
        WebViewController.show(with: .content)
    }

    // MARK: Setup UI

    private func localize() {
        title = Constants.Strings.homeScreenStartingScreenText
        titleLabel.text = Constants.Strings.homeScreenEnterSymptomsText

        navigationItem.backBarButtonItem = UIBarButtonItem(title: Constants.Strings.generalBackText,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        startButton.setTitle(Constants.Strings.homeScreenStartCapitalText, for: .normal)
        tncButton.setTitle(Constants.Strings.generalTosText, for: .normal)
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
