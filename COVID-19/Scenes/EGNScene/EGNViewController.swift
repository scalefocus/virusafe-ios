//
//  EGNViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 27.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManager

class EGNViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var egnTitleLabel: UILabel!
    @IBOutlet private weak var egnDescriptionLabel: UILabel!
    @IBOutlet private weak var egnTextField: SkyFloatingLabelTextField!
    
    @IBOutlet private weak var egnSubmitButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!
    
    // MARK: Settings

    private let maximumPersonalNumberLength = 10
    
    // MARK: View Model
    
    var viewModel:RegistrationConfirmationViewModel!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 80
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: Setup UI
    
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
    
    @IBAction private func didTapSubmitButton(_ sender: Any) {
        // TODO: Validation - lenght
        // TODO: Add API Call
        viewModel.didTapPersonalNumberAuthorization(with: egnTextField.text ?? "")
    }

    @IBAction private func didTapSkipButton(_ sender: Any) {
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

// MARK: UITextFieldDelegate

extension EGNViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maximumPersonalNumberLength
    }
}
