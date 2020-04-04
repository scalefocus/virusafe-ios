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

// MARK: Navigateble
class SplashViewController: UIViewController, Navigateble {
    // MARK: Outlets
    @IBOutlet private weak var loadingIndicatorView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var ministryOfHealthImageView: UIImageView!
    @IBOutlet private weak var operationsCenterImageView: UIImageView!
    
    // MARK: Properties
      weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner()
        //load firebase default values
        loadDefaultValues()
        // fetch remoe config
        fetchCloudValues()
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

     // MARK: Private methods
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
        let savedLocale = UserDefaults.standard.string(forKey: "userLocale") ?? "bg"
        ministryOfHealthImageView.image = UIImage(named: "ic_min_zdrave-\(savedLocale)")
        operationsCenterImageView.image =  UIImage(named: "ic_oper_shtab-\(savedLocale)")
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
extension SplashViewController {
    func loadDefaultValues() {
        print("Test")
        #if UPNETIX
        let appDefaults: [String: Any?] = [
            "ios_is_mandatory" : false,
            "ios_latest_app_version" : "1.0",
            "ios_end_point" : "https://virusafe.scalefocus.dev",
            "ios_static_content_page_url" : "https://virusafe.scalefocus.dev/information/about-covid.html",
            "ios_appstore_link" : "https://apps.apple.com/in/app/ViruSafe/id1504661908",
            "ios_location_interval_in_mins" : 2,
            "ios_app_info_page_url": "https://virusafe.scalefocus.dev/information/virusafe-why.html"
        ]
        #elseif GOVERNMENT
        let appDefaults: [String: Any?] = [
            "ios_is_mandatory" : false,
            "ios_latest_app_version" : "1.0",
            "ios_end_point" : "https://virusafe.io",
            "ios_static_content_page_url" : "https://virusafe.io/information/about-covid.html",
            "ios_appstore_link" : "https://apps.apple.com/in/app/ViruSafe/id1504661908",
            "ios_location_interval_in_mins" : 2,
            "ios_app_info_page_url": "https://virusafe.io/information/virusafe-why.html"
        ]
        #else
        // MACEDONIA
        let appDefaults: [String: Any?] = [
            "ios_is_mandatory" : false,
            "ios_latest_app_version" : "1.0",
            "ios_end_point" : "https://virusafe.io",
            "ios_static_content_page_url" : "https://virusafe.io/information/about-covid.html",
            "ios_appstore_link" : "https://apps.apple.com/in/app/ViruSafe/id1504661908",
            "ios_location_interval_in_mins" : 2,
            "ios_app_info_page_url": "https://virusafe.io/information/virusafe-why.html"
        ]
        #endif

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
//                self.showToast(message: "something_went_wrong".localized())
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
                                                                 alertTitle: "new_version_label".localized(),
                                                                 alertDescription: "new_version_msg".localized(),
                                                                 updateButtonTitle: "update_label".localized(),
                                                                 okButtonTitle: "continue_label".localized(),
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

// MARK: Networkin
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
    var url: String = "url_about_covid".localized()
}

final class AppInfoPage {
    static var shared = AppInfoPage()
    private init() { }
    var url: String = "url_virusafe_why".localized()
}
