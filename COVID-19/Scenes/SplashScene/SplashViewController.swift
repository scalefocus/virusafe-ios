//
//  SplashViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import PopupUpdate
import Firebase
import NetworkKit

class SplashViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets
    
    @IBOutlet private weak var loadingIndicatorView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        showSpinner()
        
        //load firebase default values
        loadDefaultValues()
        
        // fetch remoe config
        fetchCloudValues()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // UI
    
    private func showSpinner() {
        let indicator = UIActivityIndicatorView(frame: loadingIndicatorView.bounds)
        indicator.style = .whiteLarge
        indicator.startAnimating()

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadingIndicatorView.addSubview(indicator)
        }
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        let isUserRegistered: Bool = (TokenStore.shared.token != nil)
        navigationDelegate?.navigateTo(step: isUserRegistered ? .home : .about(isInitial: true))
    }

}

// MARK: Firebase

extension SplashViewController {
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            "ios_is_mandatory" : false,
            "ios_latest_app_version" : "1.0",
            "ios_end_point" : "https://virusafe.io",
            "ios_static_content_page_url" : "https://virusafe.io/information/about-covid.html",
            "ios_appstore_link" : "https://www.apple.com/ios/app-store/", // TODO: Actual
            "ios_location_interval_in_mins" : 2,
            "ios_app_info_page_url": ""
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func fetchCloudValues() {
        // WARNING: Don't actually do this in production!
        let fetchDuration: TimeInterval = 10
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5
        
        RemoteConfig.remoteConfig().configSettings = settings
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in
            if let error = error {
                print("Uh-oh. Got an error fetching remote values \(error)")
                // !!! safe we don't have reference to RemoteConfig.remoteConfig()
//                self.showToast(message: Constants.Strings.errorConnectionWithServerFailed)
                return
            }

            RemoteConfig.remoteConfig().activate()

            // TODO: Update AppManager Base URL with the one from the remote congig (do it with environement)

            if status == .success {
                let isMandatory = RemoteConfig.remoteConfig().configValue(forKey: "ios_is_mandatory").boolValue
                let currentAppVersion = RemoteConfig.remoteConfig().configValue(forKey: "ios_latest_app_version").stringValue
                let appstoreLink = RemoteConfig.remoteConfig().configValue(forKey: "ios_appstore_link").stringValue

                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

                PUUpdateApplicationManager.shared.checkForUpdate(shouldForceUpdate: isMandatory,
                                                                 minimumVersionNeeded: currentAppVersion ?? "1.0",
                                                                 urlToOpen: appstoreLink ?? "",
                                                                 currentVersion: appVersion,
                                                                 window: UIApplication.shared.keyWindow,
                                                                 alertTitle: Constants.Strings.newVersionAlertTitle,
                                                                 alertDescription: Constants.Strings.newVersionAlertDescription,
                                                                 updateButtonTitle: Constants.Strings.newVersionAlertUpdateButtonTitle,
                                                                 okButtonTitle: Constants.Strings.newVersionAlertOkButtonTitle,
                                                                 urlOpenedClosure: self.handleForceUpdate // !!! safe we don't have reference to RemoteConfig.remoteConfig()
                )

                // Update APIManager Base url
                guard let remoteConfigURL = RemoteConfig.remoteConfig().configValue(forKey: "ios_end_point").stringValue else {
                    return
                }
                guard var urlComponents = URLComponents(string: remoteConfigURL) else {
                    return
                }
                let port = urlComponents.port
                urlComponents.port = nil
                guard var urlString = urlComponents.url?.absoluteString else {
                    return
                }
                if urlString.suffix(1) == "/" {
                    urlString.removeLast()
                }
                let baseURL = RemoteStageBaseURLs(base: urlString, port: port)
                let remoteEnvironment = RemoteConfigEnvironment(baseURLs: baseURL)
                APIManager.shared.remoteEnvironment = remoteEnvironment

                // update static content page url
                if let staticContentURL = RemoteConfig.remoteConfig().configValue(forKey: "ios_static_content_page_url").stringValue {
                    StaticContentPage.shared.url = staticContentURL
                }
            }
        }
    }

    private func handleForceUpdate(error: PUUpdateApplicationError?) -> Void {
        if let error = error, error != .noUpdateNeeded {
            print("Error Supported version: \(error)")
            return
        }
        // !!! Prevent navigation - solves issue when user gets back from app store and app is not updated
        if RemoteConfig.remoteConfig().configValue(forKey: "ios_is_mandatory").boolValue {
            print("Update is mandatory")
            return
        }
        navigateToNextViewController()
    }
}

// MARK: ToastViewPresentable

extension SplashViewController: ToastViewPresentable {}

// MARK: Networking

struct RemoteConfigEnvironment: EnvironmentInterface {
    var name = "FirebaseConfig"
    var baseURLs: BaseURLs
    var serverTrustPolicies: APITrustPolicies = [:]
}

struct RemoteStageBaseURLs: BaseURLs {
    var base: BaseURL
    var port: Int?
}

final class StaticContentPage {
    static var shared = StaticContentPage()
    private init() { }
    var url: String = "https://virusafe.io/information/about-covid.html"
}

final class AppInfoPage {
    static var shared = AppInfoPage()
    private init() { }
    var url: String = RemoteConfig.remoteConfig().configValue(forKey: "ios_app_info_page_url").stringValue ?? ""
}
