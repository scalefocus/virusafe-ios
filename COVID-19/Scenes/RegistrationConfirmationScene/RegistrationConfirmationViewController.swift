//
//  RegistrationConfirmationViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManager
import FontAwesome_swift

class RegistrationConfirmationViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var mobileNumberLabel: UILabel!
    @IBOutlet private weak var verificationCodeTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var noCodeReceivedButton: UIButton!

    // MARK: Settings

    private let maximumValidationCodeLength = 6

    // MARK: View Model

    // Injected from parent in order to get its instance of the RegistrationRepository
    var viewModel: RegistrationConfirmationViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()

        mobileNumberLabel.text = "phone_text".localized() +
            ": " + viewModel.mobileNumber()
        textLabel.text = "verification_code_title".localized().replacingOccurrences(of: "\\n", with: "\n")
        confirmButton.setTitle("confirm_label".localized(), for: .normal)
        noCodeReceivedButton.setTitle("missing_verification_code".localized(), for: .normal)

        if #available(iOS 12.0, *) {
            verificationCodeTextField.textContentType = .oneTimeCode
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()

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
        title = "verify_sms_screen_title".localized().replacingOccurrences(of: "\\n", with: "\n")
        confirmButton.backgroundColor = .healthBlue
        setupIconImageViewTint()
        setupVerificationCodeTextField()
    }

    private func setupIconImageViewTint() {
        let image =  UIImage.fontAwesomeIcon(name: .userShield,
                                             style: .light,
                                             textColor: .healthBlue ?? .blue,
                                             size: iconImageView.frame.size)
        iconImageView.image = image
    }

    private func setupVerificationCodeTextField() {
        verificationCodeTextField.borderStyle = .none
        verificationCodeTextField.placeholder = "verification_code_hint".localized() + " "
        // By default title will be same as placeholder
        verificationCodeTextField.errorColor = .red
        // !!! other styles are in stotyboard
    }

    //swiftlint:disable:next cyclomatic_complexity
    private func setupBindings() {
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                strongSelf.verificationCodeTextField.resignFirstResponder()
                LoadingIndicatorManager.startActivityIndicator(.gray,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }

        viewModel.isCodeAuthorizationRequestSuccessful.bind { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.navigateToNextViewController()
            case .invalidPhoneNumber:
                strongSelf.showToast(message: "invalid_phone_msg".localized())
            case .invalidPin:
                strongSelf.showToast(message: "invalid_pin_msg".localized())
            default:
                strongSelf.showToast(message: "no_internet_msg".localized())
            }
        }

        viewModel.isResendCodeRequestSuccessful.bind { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.showToast(message: "verification_code_send_again".localized())
            case .invalidPhoneNumber:
                strongSelf.showToast(message: "invalid_phone_msg".localized())
            case .tooManyRequests(let reapeatAfter):
                let alert = UIAlertController.rateLimitExceededAlert(repeatAfterSeconds: reapeatAfter)
                self?.present(alert, animated: true, completion: nil)
            default:
                strongSelf.showToast(message: "no_internet_msg".localized())
            }
        }

    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        // !!! Do it as it is done on Android - always do full initial flow
        navigationDelegate?.navigateTo(step: .personalInformation)
    }

    // MARK: Actions

    @IBAction private func resetCodeButtonDidTap (_ sender: Any) {
        viewModel.didTapResetCodeButton()
    }

    @IBAction private func didTapConfirmButton(_ sender: Any) {
        guard let authorizationCode = verificationCodeTextField.text else { return }

        if authorizationCode.count < 6 {
            errorLabel.isHidden = false
            errorLabel.text = "field_invalid_format_msg".localized()
            return
        } else if !authorizationCode.isDigitsOnly {
            errorLabel.isHidden = false
            errorLabel.text = "field_invalid_format_msg".localized()
            return
        } else {
            errorLabel.isHidden = true
            viewModel.didTapCodeAuthorization(with: authorizationCode)
        }
    }

}

// MARK: UITextFieldDelegate

extension RegistrationConfirmationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString

        return newString.length <= maximumValidationCodeLength
    }
}

// MARK: ToastViewPresentable

extension RegistrationConfirmationViewController: ToastViewPresentable {}
