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
    
    @IBOutlet private weak var loadingIndicatorView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        showSpinner()
        
        //load firebase default values
        loadDefaultValues()
        
        // fetch remoe config
        fetchCloudValues()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    private func showSpinner() {
        let indicator = UIActivityIndicatorView(frame: loadingIndicatorView.bounds)
        indicator.style = .whiteLarge
        indicator.startAnimating()

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadingIndicatorView.addSubview(indicator)
        }
    }
    
}

//Firebase
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
          return
        }
        
        RemoteConfig.remoteConfig().activate()
        
        if status == .success {
            let isMandatory = RemoteConfig.remoteConfig().configValue(forKey: "iso_is_mandatory").boolValue
            let currentAppVersion = RemoteConfig.remoteConfig().configValue(forKey: "ios_latest_app_version").stringValue
            
            PUUpdateApplicationManager.shared.checkForUpdate(shouldForceUpdate: isMandatory,
                                                               minimumVersionNeeded: "2",
                                                               urlToOpen: "https://www.upnetix.com/",
                                                               currentVersion: currentAppVersion,
                                                               window: UIApplication.shared.keyWindow,
                                                               alertTitle: "Нова версия",
                                                               alertDescription: "Има подобрения по приложението, моля свалете новата версия",
                                                               updateButtonTitle: "Обнови",
                                                               okButtonTitle: "Продължи",
                                                               urlOpenedClosure:  { [weak self] error in
                                                                  if let error = error {
                                                                      print("Error Supported version: \(error)")
                                                                  }
                                                                 
                                                                  let isUserRegistered = UserDefaults.standard.bool(forKey: "isUserRegistered")
                                                                  
                                                                  self?.showVC(with: isUserRegistered
                                                                  ? "\(HomeViewController.self)"
                                                                  : "\(RegistrationViewController.self)")
              })
        }
      }
    }
}
