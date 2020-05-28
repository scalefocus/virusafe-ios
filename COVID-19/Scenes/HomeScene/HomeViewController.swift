//
//  HomeViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import Firebase

// TODO: Refactor to MVVM
class HomeViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var howItWorksButton: UIButton!
    @IBOutlet private weak var personalInfoButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tncButton: UIButton!
    @IBOutlet private weak var personalDataProtectionButton: UIButton!
    @IBOutlet private weak var statisticsButton: UIButton!
    @IBOutlet private weak var moreInfoButton: UIButton!
    @IBOutlet private weak var languagesButton: UIButton!
    @IBOutlet private weak var titleDescriptionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        askForPushNotifications()

        // Listen for token changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeFCMToken(_:)),
                                               name: NSNotification.Name("FCMToken"),
                                               object: nil)

        let statisticsButtonVisible = RemoteConfigHelper.shared.isStatisticsButtonVisible
        statisticsButton.isHidden = !statisticsButtonVisible

        sendPushToken()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        localize()

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
        navigationDelegate?.navigateTo(step: .personalInformation(shouldNavigateToHealthStatus: false))
    }

    @IBAction private func didTapSurveyButton(_ sender: Any) {
        guard TermsAndConditionsRepository().isAgreeDataProtection else {
            presentPrivacyPolicyNotAcceptedAlertMessage()
            return
        }
        navigationDelegate?.navigateTo(step: .healthStatus)
    }

    @IBAction private func tncButtonTap() {
        navigationDelegate?.navigateTo(step: .termsAndConditions(type: .termsAndConditions))
    }

    @IBAction private func personalDataProtectionButtonTap() {
        navigationDelegate?.navigateTo(step: .termsAndConditions(type: .processPersonalData))
    }

    @IBAction private func languagesButtonTap() {
        navigationDelegate?.navigateTo(step: .languages(isInitial: false))
    }

    @IBAction func didTapStatisticsButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .web(source: .statistics))
    }

    @IBAction private func moreInfoDidTap() {
        navigationDelegate?.navigateTo(step: .web(source: .content))
    }

    // MARK: Setup UI

    private func localize() {
        titleLabel.text = "my_contribution_title".localized().uppercased()
        titleDescriptionLabel.text = "my_contribution_title_description".localized()
        howItWorksButton.setTitle("how_it_works".localized().uppercased(), for: .normal)
        statisticsButton.setTitle("statistics_label".localized().uppercased(), for: .normal)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "back_text".localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        startButton.setTitle("how_do_you_feel_today".localized().uppercased(), for: .normal)
        personalInfoButton.setTitle("my_personal_data".localized().uppercased(), for: .normal)
        tncButton.setTitle("terms_n_conditions_label".localized(), for: .normal)
        personalDataProtectionButton.setTitle("data_protection_notice_label".localized(), for: .normal)
        moreInfoButton.setTitle("learn_more".localized().uppercased(), for: .normal)
        languagesButton.setTitle("language".localized(), for: .normal)
        let globe =  UIImage.fontAwesomeIcon(name: .globe,
                                             style: .light,
                                             textColor: .healthBlue ?? .blue,
                                             size: CGSize(width: 24, height: 24))
        languagesButton.setImage(globe, for: .normal)

        // Change privacy icon tint
        let image = imageView.image
        let newImage = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = startButton.tintColor
        imageView.image = newImage
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

    @objc
    private func didChangeFCMToken(_ notification: Notification) {
        sendPushToken()
    }

    private func sendPushToken() {
        let userDefaults = UserDefaults.standard
        let fcmToken = PushTokenStore.shared.fcmToken ?? ""
        // !!! Token was already registered with the server
        guard userDefaults.string(forKey: "push_token") != fcmToken else {
            return
        }

        RegistrationRepository().registerPushToken(fcmToken) { result in
            switch result {
            case .success:
                userDefaults.set(fcmToken, forKey: "push_token")
                userDefaults.synchronize()
            case .failure:
                // No error handling - this should be silent
                break
            }
        }
    }

    // MARK: Alert

    private func presentPrivacyPolicyNotAcceptedAlertMessage() {
        let alert = UIAlertController(title: nil,
                                      message: "popup_accept_personal_data_usage".localized(),
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "popup_proceed_btn".localized(), style: .default) { [weak self] _ in
            self?.navigationDelegate?.navigateTo(step: .personalInformation(shouldNavigateToHealthStatus: true))
        }
        let cancel = UIAlertAction(title: "back_text".localized(), style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

}
