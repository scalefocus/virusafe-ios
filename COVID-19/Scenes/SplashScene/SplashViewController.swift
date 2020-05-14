//
//  SplashViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import PopupUpdate
import NetworkKit

// MARK: Navigateble
class SplashViewController: UIViewController, Navigateble {

    // MARK: Outlets

    @IBOutlet private weak var loadingIndicatorView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var ministryOfHealthImageView: UIImageView!
    @IBOutlet private weak var operationsCenterImageView: UIImageView!

    @IBOutlet var appNameLabel: UILabel!

    // MARK: Properties

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        showSpinner()

        // ??? Use bundle name instead
        #if MACEDONIA
        appNameLabel.text = "SeZaCOVID19"
        #else
        appNameLabel.text = "ViruSafe"
        #endif

        // setup images views depending on the locale
        setupImages()

        // Fetch remote config
        RemoteConfigHelper.shared.fetchRemoteConfigValues(fetchRemoteConfigCompletionHandler)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: UI methods

    private func showSpinner() {
        let indicator = UIActivityIndicatorView(frame: loadingIndicatorView.bounds)
        indicator.style = .whiteLarge
        indicator.startAnimating()
        loadingIndicatorView.addSubview(indicator)
    }

    private func setupImages() {
        #if !MACEDONIA
        let savedLocale = LanguageHelper.shared.savedLocale
        ministryOfHealthImageView.image = UIImage(named: "ic_min_zdrave-\(savedLocale)")
        operationsCenterImageView.image = UIImage(named: "ic_oper_shtab-\(savedLocale)")
        #endif
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        let isUserRegistered: Bool = (TokenStore.shared.token != nil)
        let isAppLaunchedBefore = AppLaunchRepository().isAppLaunchedBefore
        switch (isUserRegistered, isAppLaunchedBefore) {
        case (true, true):
            // Initial flow completed at some point user returns to app
            navigationDelegate?.navigateTo(step: .home)
        case (false, true):
            // App was killed after expired session and now user returns
            navigationDelegate?.navigateTo(step: .register)
        default:
            // First run or killed after confirm pin
            navigationDelegate?.navigateTo(step: .languages(isInitial: true))
        }
    }

}

// MARK: Firebase

private extension SplashViewController {

    func fetchRemoteConfigCompletionHandler() {
        // Check for forced update version
        PUUpdateApplicationManager.shared.checkForUpdate(
            shouldForceUpdate: RemoteConfigHelper.shared.isLatestAppVersionMandatory,
            minimumVersionNeeded: RemoteConfigHelper.shared.latestAppVersion,
            urlToOpen: RemoteConfigHelper.shared.appstoreLink,
            currentVersion: Bundle.main.releaseVersionNumber,
            window: UIApplication.shared.keyWindow,
            alertTitle: "new_version_label".localized(),
            alertDescription: "new_version_msg".localized(),
            updateButtonTitle: "update_label".localized(),
            okButtonTitle: "continue_label".localized(),
            urlOpenedClosure: handleForceUpdate
        )

        // NOTE: Info Web Pages URLs are in localizations

        // set remote config url as base for the communication
        APIManager.shared.baseURLs = BaseURLs(base: RemoteConfigHelper.shared.endpointURL)

        // Update statistics Page URL
        StatisticsPage.shared.url = RemoteConfigHelper.shared.statisticsPageURL
    }

}

// MARK: Force Upate

private extension SplashViewController {

    func handleForceUpdate(error: PUUpdateApplicationError?) {
        if let error = error, error != .noUpdateNeeded {
            print("Error Supported version: \(error)")
            return
        }

        // !!! Prevent navigation - solves issue when user gets back from app store and app is not updated
        if RemoteConfigHelper.shared.isLatestAppVersionMandatory {
            print("Update is mandatory")
            return
        }

        navigateToNextViewController()
    }

}

// MARK: ToastViewPresentable

extension SplashViewController: ToastViewPresentable { }
