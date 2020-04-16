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
import FontAwesome_swift

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
    @IBOutlet private weak var personalDataProtectionButton: UIButton!
    @IBOutlet private weak var personalDataCheckbox: CheckBox!

    // MARK: Settings

    private let phoneNumberMaxLength = 15

    // MARK: View Model

    // Injected from parent in order to get its instance of the RegistrationRepository
    var viewModel: RegistrationViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupUI()

        navigationController?.setNavigationBarHidden(true, animated: animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 120
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        // TODO: Bind it
        checkBox.isSelected = viewModel.termsAndConditionsRepository.isAgree
        personalDataCheckbox.isSelected = viewModel.termsAndConditionsRepository.isAgreeDataProtection
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
        confirmButton.setTitle("confirm_label".localized(), for: .normal)
        registrationLabel.text = "registration_title".localized()
        setupButton(tncButton,
                    text: "i_agree_with_label".localized(),
                    link: "terms_n_conditions_small_caps_label".localized(),
                    for: .normal)
        setupButton(personalDataProtectionButton,
                    text: "i_consent_to_label".localized(),
                    link: "data_protection_notice_small_caps_label".localized(),
                    for: .normal)
        setupIconImageViewTint()
        setupPhoneNumberTextField()
    }

    private func setupIconImageViewTint() {
        iconImageView.image = UIImage.fontAwesomeIcon(name: .user,
                                                      style: .light,
                                                      textColor: .healthBlue ?? .blue,
                                                      size: iconImageView.frame.size)
    }

    private func setupPhoneNumberTextField() {
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.placeholder = "mobile_hint".localized()
        // By default title will be the same
        phoneNumberTextField.errorColor = .red
        // !!! other styles are in stotyboard
    }

    private func setupButton(_ button: UIButton, text: String, link: String, for state: UIControl.State) {
        let font = UIFont.systemFont(ofSize: 12)
        let textColor = UIColor.darkText
        let linkColor = (UIColor.healthBlue ?? UIColor.blue).withAlphaComponent(0.79)
        let attributesText: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let attributesLink: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: linkColor
        ]
        let attributedTitle = NSMutableAttributedString()
        attributedTitle.append(
            NSAttributedString(string: "\(text) ", attributes: attributesText)
        )
        attributedTitle.append(
            NSAttributedString(string: "\(link)", attributes: attributesLink)
        )
        button.setAttributedTitle(attributedTitle, for: .normal)

        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
    }

    // MARK: Setup bindings

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
                strongSelf.showToast(message: "invalid_phone_msg".localized())
            case .tooManyRequests(let reapeatAfter):
                let alert = UIAlertController.rateLimitExceededAlert(repeatAfterSeconds: reapeatAfter)
                self?.present(alert, animated: true, completion: nil)
            default:
                strongSelf.showToast(message: "no_internet_msg".localized())
            }
        }
    }

    // MARK: Actions

    @IBAction private func didTapRegisterButton(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count >= 5 else {
            errorLabel.isHidden = false
            errorLabel.text = "field_length_error_msg".localized()
            return
        }

        guard phoneNumber.isPhoneNumber else {
            errorLabel.isHidden = false
            errorLabel.text = "field_invalid_format_msg".localized()
            return
        }

        errorLabel.isHidden = true

        guard checkBox.isSelected else {
            let alert = UIAlertController(title: "warning_label".localized(),
                                          message: "error_accept_terms_and_conditions".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok_label".localized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        guard personalDataCheckbox.isSelected else {
            let alert = UIAlertController(title: "warning_label".localized(),
                                          message: "error_accept_personal_data_access".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok_label".localized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        viewModel.didTapRegistration(with: phoneNumber)
    }

    @IBAction private func checkBoxDidTap() {
        viewModel.termsAndConditionsRepository.isAgree.toggle()// = !viewModel.termsAndConditionsRepository.isAgree
        checkBox.isSelected = viewModel.termsAndConditionsRepository.isAgree
    }

    @IBAction private func tncButtonDidTap() {
        navigationDelegate?.navigateTo(step: .termsAndConditions(type: .termsAndConditions))
    }

    @IBAction private func didTapPrivacyPolicyCheckbox(_ sender: Any) {
        viewModel.termsAndConditionsRepository.isAgreeDataProtection.toggle()
        personalDataCheckbox.isSelected = viewModel.termsAndConditionsRepository.isAgreeDataProtection
    }

    @IBAction private func didTapPrivacyPolicyInfoButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .termsAndConditions(type: .processPersonalData))
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
