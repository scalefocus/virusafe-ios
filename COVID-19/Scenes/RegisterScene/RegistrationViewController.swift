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
    @IBOutlet private weak var checkBox: CheckBox!
    @IBOutlet private weak var tncButton: UIButton!
    @IBOutlet private weak var registrationLabel: UILabel!

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
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 120
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
        registrationLabel.text = Constants.Strings.registrationScreenTitle
        setupBackButton()
        setupIconImageViewTint()
        setupPhoneNumberTextField()
    }

    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Constants.Strings.navigationBackButtonTitle,
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
                LoadingIndicatorManager.startActivityIndicator(.whiteLarge,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }

        viewModel.isRequestSuccessful.bind { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success:
                    strongSelf.showRegistrationConfirmation()
                case .generalError:
                    strongSelf.showToast(message: "Грешка. Проверете дали сте свързани с интернет и опитайте отново.")
                case .invalidPhoneNumber:
                    strongSelf.showToast(message: "Грешка. Невалиден телефонен номер.")
            }
        }
    }

    // MARK: Navigation

    private func showRegistrationConfirmation() {
        guard let registrationConfirmationVC =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(RegistrationConfirmationViewController.self)")
                as? RegistrationConfirmationViewController else {
                    assertionFailure("RegistrationConfirmationViewController is not found")
                    return
        }
        registrationConfirmationVC.viewModel =
            RegistrationConfirmationViewModel(repository: viewModel.repository)
        navigationController?.pushViewController(registrationConfirmationVC, animated: true)
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
            errorLabel.text = "Невалиден формат"
            return
        }

        errorLabel.isHidden = true

        guard checkBox.isSelected else {
            let alert = UIAlertController(title: "Внимание",
                                          message: "За да бъде запазена регистрацията Ви е необходимо да сте съгласни с Общите условия на приложението.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Добре", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        viewModel.didTapRegistration(with: phoneNumber)
    }

    @IBAction private func checkBoxDidTap() {
        checkBox.isSelected = !checkBox.isSelected
    }

    @IBAction private func tncButtonDidTap() {
        guard let tncViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "\(TermsAndConditionsViewController.self)")
            as? TermsAndConditionsViewController else {
                assertionFailure("TermsAndConditionsViewController is not found")
                return
        }
        tncViewController.viewModel = TermsAndConditionsViewModel(isAcceptButtonVisible: !checkBox.isSelected)
        tncViewController.userResponseHandler = { [weak self] isAgree in
            self?.checkBox.isSelected = isAgree
            self?.navigationController?.popViewController(animated: false)
        }
        navigationController?.pushViewController(tncViewController, animated: true)
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

extension Constants.Strings {
    static let registrationScreenTitle = "Регистрация"
    static let registrationScreenPhoneTextFieldPlaceholder = "Телефонен номер"
    static let navigationBackButtonTitle = "Назад"

    static let registrationScreenPhoneTextFieldEmpty = "Полето не може да е празно"
    static let registrationScreenPhoneTextFieldInvalidLenght = "Полето трябва да съдържа повече символи"
    static let registrationScreenPhoneTextFieldInvalidFormat = "Невалиден формат"
}
