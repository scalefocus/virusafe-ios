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

class SplashViewController: UIViewController {

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
        showVC(with: isUserRegistered ? "\(HomeViewController.self)" : "\(RegistrationViewController.self)")
    }

    private func showVC(with identifier: String) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }

        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        let navigationController = UINavigationController(rootViewController: homeViewController)
        keyWindow.rootViewController = navigationController
        UIView.transition(with: keyWindow,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
}

// MARK: Firebase

extension SplashViewController {
    
    func loadDefaultValues() {
      let appDefaults: [String: Any?] = [
        "is_mandatory" : false,
        "latest_app_version" : "1"
      ]
      RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func fetchCloudValues() {
        // WARNING: Don't actually do this in production!
        let fetchDuration: TimeInterval = 0
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        
        RemoteConfig.remoteConfig().configSettings = settings
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in

        if let error = error {
            print("Uh-oh. Got an error fetching remote values \(error)")
            // !!! safe we don't have reference to RemoteConfig.remoteConfig()
            self.showToast(message: Constants.Strings.errorConnectionWithServerFailed)
          return
        }
        
        RemoteConfig.remoteConfig().activate()
        
        if status == .success {
            let isMandatory = RemoteConfig.remoteConfig().configValue(forKey: "iso_is_mandatory").boolValue
            let currentAppVersion = RemoteConfig.remoteConfig().configValue(forKey: "ios_latest_app_version").stringValue
            
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            
            PUUpdateApplicationManager.shared.checkForUpdate(shouldForceUpdate: isMandatory,
                                                             minimumVersionNeeded: currentAppVersion!,
                                                             urlToOpen: "https://www.upnetix.com/",
                                                             currentVersion: appVersion,
                                                             window: UIApplication.shared.keyWindow,
                                                             alertTitle: Constants.Strings.newVersionAlertTitle,
                                                             alertDescription: Constants.Strings.newVersionAlertDescription,
                                                             updateButtonTitle: Constants.Strings.newVersionAlertUpdateButtonTitle,
                                                             okButtonTitle: Constants.Strings.newVersionAlertOkButtonTitle,
                                                             // !!! safe we don't have reference to RemoteConfig.remoteConfig()
                                                             urlOpenedClosure: self.handleForceUpdate
            )
        }
      }
    }

    private func handleForceUpdate(error: PUUpdateApplicationError?) -> Void {
        if let error = error, error != .noUpdateNeeded {
            print("Error Supported version: \(error)")
            return
        }
        // !!! Prevent navigation - solves issue when user gets back from app store and app is not updated
        if RemoteConfig.remoteConfig().configValue(forKey: "iso_is_mandatory").boolValue {
            print("Update is mandatory")
            return
        }
        navigateToNextViewController()
    }
}

// MARK: ToastViewPresentable

extension SplashViewController: ToastViewPresentable {}

enum Constants {
    enum Strings {
        static let newVersionAlertTitle = "Нова версия"
        static let newVersionAlertDescription = "Има обновления по приложението"
        static let newVersionAlertUpdateButtonTitle = "Обнови"
        static let newVersionAlertOkButtonTitle = "Продължи"

        static let errorConnectionWithServerFailed = "Опа! Нещо се обърка"
    }
}

