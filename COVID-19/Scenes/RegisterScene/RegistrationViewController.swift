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

class RegistrationViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var phoneNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var checkBox: CheckBox!
    @IBOutlet private weak var tncButton: UIButton!
    @IBOutlet private weak var registrationLabel: UILabel!
    @IBOutlet private weak var iAgreeWithLabel: UILabel!
    
    // MARK: Settings

    private let phoneNumberMaxLength = 15

    // MARK: View Model

    // Injected from parent in order to get its instance of the RegistrationRepository
    var viewModel: RegistrationViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 120
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        checkBox.isSelected = viewModel.termsAndConditionsRepository.isAgree
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
        registrationLabel.text = Constants.Strings.registrationScreenTitle
        iAgreeWithLabel.text = Constants.Strings.iAgreeWithText + " "
        tncButton.setTitle(Constants.Strings.registrationScreenTocText, for: .normal)
        setupIconImageViewTint()
        setupPhoneNumberTextField()
    }

    private func setupIconImageViewTint() {
        let userIcon = #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        iconImageView.image = userIcon
        iconImageView.tintColor = .healthBlue
    }

    private func setupPhoneNumberTextField() {
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.placeholder = Constants.Strings.registrationScreenPhoneTextFieldPlaceholder
        // By default title will be the same
        phoneNumberTextField.errorColor = .red
        // !!! other styles are in stotyboard
    }

    private func setupBindings() {
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                strongSelf.phoneNumberTextField.resignFirstResponder()
                LoadingIndicatorManager.startActivityIndicator(.gray,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }

        viewModel.isRequestSuccessful.bind { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success:
                    strongSelf.navigationDelegate?.navigateTo(step: .registerConfirm)
                case .invalidPhoneNumber:
                    strongSelf.showToast(message: Constants.Strings.registrationScreenInvalindNumberErrorText)
                default:
                    strongSelf.showToast(message: Constants.Strings.registrationScreenGeneralErrorText)
            }
        }
    }

    // MARK: Actions
    
    @IBAction private func didTapRegisterButton(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count >= 5 else {
            errorLabel.isHidden = false
            errorLabel.text = Constants.Strings.registrationScreenPhoneTextFieldInvalidLenght
            return
        }

        guard phoneNumber.isPhoneNumber else {
            errorLabel.isHidden = false
            errorLabel.text = Constants.Strings.generalErrorIncorrectFormatText
            return
        }

        errorLabel.isHidden = true

        guard checkBox.isSelected else {
            let alert = UIAlertController(title: Constants.Strings.generalWarningText,
                                          message: Constants.Strings.registrationScreenTOSText,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Strings.genaralAgreedText, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        viewModel.didTapRegistration(with: phoneNumber)
    }

    @IBAction private func checkBoxDidTap() {
        viewModel.termsAndConditionsRepository.isAgree = !viewModel.termsAndConditionsRepository.isAgree
        checkBox.isSelected = viewModel.termsAndConditionsRepository.isAgree
    }

    @IBAction private func tncButtonDidTap() {
        navigationDelegate?.navigateTo(step: .termsAndConditions)
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

// MARK: ToastViewPresentable

extension RegistrationViewController: ToastViewPresentable {}
