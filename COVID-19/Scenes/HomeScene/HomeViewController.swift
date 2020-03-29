//
//  HomeViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var howItWorksButton: UIButton!
    @IBOutlet private weak var personalInfoButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tncButton: UIButton!
    @IBOutlet private weak var moreInfoButton: UIButton!
    @IBOutlet private weak var icon: UIImageView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        localize()
        askForPushNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: Actions

    @IBAction private func didTapHowItWorksButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .about(isInitial: false))
    }
    
    @IBAction private func didTapMyPersonalInfoButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .personalInformation)
    }
    
    @IBAction private func didTapSurveyButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .healthStatus)
    }

    @IBAction private func tncButtonTap() {
        navigationDelegate?.navigateTo(step: .termsAndConditions)
    }

    @IBAction private func moreInfoDidTap() {
        navigationDelegate?.navigateTo(step: .web(source: .about))
    }

    // MARK: Setup UI
    
    private func setupButtons() {
        moreInfoButton.borderColor = .healthBlue ?? .black
        startButton.borderColor = .healthBlue ?? .black
        personalInfoButton.borderColor = .healthBlue ?? .black
        howItWorksButton.borderColor = .healthBlue ?? .black
    }

    private func localize() {
        title = Constants.Strings.homeScreenStartingScreenText
        titleLabel.text = Constants.Strings.homeScreenMyPersonalContributionText
        howItWorksButton.setTitle(Constants.Strings.homeScreenHowItWorksText, for: .normal)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Constants.Strings.generalBackText,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        startButton.setTitle(Constants.Strings.homeScreenMySymptomsText, for: .normal)
        personalInfoButton.setTitle(Constants.Strings.homeScreenMyPersonalInfoText, for: .normal)
        tncButton.setTitle(Constants.Strings.generalTosText, for: .normal)
    }

    // MARK: Push Notifications

    // TODO: Refactor This should be in manager class
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
