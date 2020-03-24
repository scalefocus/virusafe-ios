//
//  ViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManager

class RegistrationViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var phoneNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!

    // MARK: Settings

    private let phoneNumberMaxLength = 15

    // MARK: View Model

    private let viewModel = RegistrationViewModel(repository: RegistrationRepository())

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 80
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: Setup UI

    private func setupUI() {
        confirmButton.backgroundColor = .healthBlue
        setupBackButton()
        setupIconImageViewTint()
        setupPhoneNumberTextField()
    }

    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }

    private func setupIconImageViewTint() {
        let userIcon = #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        iconImageView.image = userIcon
        iconImageView.tintColor = .healthBlue
    }

    private func setupPhoneNumberTextField() {
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.placeholder = "Въведете мобилен телефон"
        // By default title will be the same
        phoneNumberTextField.errorColor = .red
        // !!! other styles are in stotyboard
    }

    private func setupBindings() {
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                strongSelf.phoneNumberTextField.resignFirstResponder()
                LoadingIndicatorManager.startActivityIndicator(.whiteLarge,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }

        viewModel.isRequestSuccessful.bind { [weak self] isRequestSuccessful in
            guard let strongSelf = self else { return }

            if isRequestSuccessful {
                guard let registrationConfirmationVC =
                    UIStoryboard(name: "Main", bundle: nil)
                        .instantiateViewController(withIdentifier: "\(RegistrationConfirmationViewController.self)")
                        as? RegistrationConfirmationViewController else {
                            assertionFailure("RegistrationConfirmationViewController is not found")
                            return
                }
                registrationConfirmationVC.viewModel =
                    RegistrationConfirmationViewModel(repository: strongSelf.viewModel.repository)
                strongSelf.navigationController?.pushViewController(registrationConfirmationVC,
                                                                    animated: true)
            } else {
                // TODO: Show popup that something is wrong
            }
        }
    }

    // MARK: Actions
    
    @IBAction private func didTapRegisterButton(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text else { return }
        
        if phoneNumber.count < 5 {
            errorLabel.isHidden = false
            errorLabel.text = "Невалидна дължина"
            return
        } else if !phoneNumber.isPhoneNumber {
            errorLabel.isHidden = false
            errorLabel.text = "Невалиден формат"
            return
        } else {
            errorLabel.isHidden = true
            viewModel.didTapRegistration(with: phoneNumber)
        }
    }
    
}

// MARK: UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= phoneNumberMaxLength
    }
}