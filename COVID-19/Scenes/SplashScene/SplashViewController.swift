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
    
    private var remoteConfig:RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSpinner()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PUUpdateApplicationManager.shared.checkForUpdate(shouldForceUpdate: false,
                                                         minimumVersionNeeded: "2",
                                                         urlToOpen: "https://www.upnetix.com/",
                                                         currentVersion: "1",
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
