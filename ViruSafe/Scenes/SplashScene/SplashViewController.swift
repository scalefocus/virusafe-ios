//
//  SplashViewController.swift
//  ViruSafe
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
        showSpinner()
        // Fetch remote config
        RemoteConfigHelper.shared.fetchRemoteConfigValues(fetchRemoteConfigCompletionHandler)

        // ??? Use bundle name instead
        #if MACEDONIA
            appNameLabel.text = "SeZaCOVID19"
        #else
            appNameLabel.text = "ViruSafe"
        #endif

        // setup images views depending on the locale
        setupImages()
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

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadingIndicatorView.addSubview(indicator)
        }
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
        // TODO: Refactor to use info dictionary wrapper
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        // Check for forced update version
        PUUpdateApplicationManager.shared.checkForUpdate(
            shouldForceUpdate: RemoteConfigHelper.shared.isLatestAppVersionMandatory,
            minimumVersionNeeded: RemoteConfigHelper.shared.latestAppVersion,
            urlToOpen: RemoteConfigHelper.shared.appstoreLink,
            currentVersion: appVersion,
            window: UIApplication.shared.keyWindow,
            alertTitle: "new_version_label".localized(),
            alertDescription: "new_version_msg".localized(),
            updateButtonTitle: "update_label".localized(),
            okButtonTitle: "continue_label".localized(),
            urlOpenedClosure: self.handleForceUpdate // !!! safe we don't have reference to RemoteConfig.remoteConfig()
        )
        // Update Network Manager URL
        updateApiManagerBaseURL()
    }

    func updateApiManagerBaseURL() {
        guard var urlComponents = URLComponents(string: RemoteConfigHelper.shared.endpointURL) else {
            return
        }
        // Avoid encode : before port
        let port = urlComponents.port
        urlComponents.port = nil
        guard var urlString = urlComponents.url?.absoluteString else {
            return
        }
        if urlString.suffix(1) == "/" {
            urlString.removeLast()
        }
        // set remote env config
        let baseURL = RemoteStageBaseURLs(base: urlString, port: port)
        let remoteEnvironment = RemoteConfigEnvironment(baseURLs: baseURL)
        APIManager.shared.remoteEnvironment = remoteEnvironment
    }

}

// MARK: Force Upate

private extension SplashViewController {

    func handleForceUpdate(error: PUUpdateApplicationError?) -> Void {
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
