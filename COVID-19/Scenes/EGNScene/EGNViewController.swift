//
//  EGNViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 27.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class EGNViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var egnTitleLabel: UILabel!
    @IBOutlet weak var egnDescriptionLabel: UILabel!
    @IBOutlet weak var egnTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var egnSubmitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    // MARK: View Model
    
    private let viewModel = RegistrationViewModel(repository: RegistrationRepository())
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        title = Constants.Strings.mobileNumberVerificationТext
        egnSubmitButton.backgroundColor = .healthBlue
        setupEgnTextField()
        egnTitleLabel.text = Constants.Strings.egnRequestText
        egnDescriptionLabel.text = Constants.Strings.egnDescriptionText
        egnTextField.placeholder = Constants.Strings.egnRequestPlacegolderText
        egnSubmitButton.setTitle(Constants.Strings.egnSubmitText, for: .normal)
        skipButton.setTitle(Constants.Strings.egnSkipText, for: .normal)
    
    }
    
    private func setupEgnTextField() {
        egnTextField.borderStyle = .none
        egnTextField.placeholder = Constants.Strings.mobileNumberEnterPinText + " "
        // By default title will be same as placeholder
        egnTextField.errorColor = .red
        // !!! other styles are in stotyboard
    }
    
    // MARK: Actions
    
    @IBAction func didTapSubmitButton(_ sender: Any) {
        showHomeModule()
    }

    @IBAction func didTapSkipButton(_ sender: Any) {
        showHomeModule()
    }
    
    // MARK: Navigation

    private func showHomeModule() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(HomeViewController.self)")
        let navigationController = UINavigationController(rootViewController: homeViewController)
        keyWindow.rootViewController = navigationController
        
        UIView.transition(with: keyWindow,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
}
