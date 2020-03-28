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

class EGNViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Outlets
    
    @IBOutlet private weak var egnTitleLabel: UILabel!
    @IBOutlet private weak var egnDescriptionLabel: UILabel!
    @IBOutlet private weak var egnTextField: SkyFloatingLabelTextField!
    
    @IBOutlet private weak var egnSubmitButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!
    
    // MARK: Settings

    private let maximumPersonalNumberLength = 10
    
    // MARK: View Model
    
    var viewModel: PersonalInformationViewModel!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
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

    // MARK: Bind

    private func setupBindings() {
        viewModel.isPersonalNumberRequestSuccessful.bind { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success:
                    strongSelf.viewModel.didTapSkipButton()
                case .invalidPersonalNumber:
                    strongSelf.showToast(message: Constants.Strings.registrationScreenInvalindPersonalNumberErrorText)
                default:
                    strongSelf.showToast(message: Constants.Strings.registrationScreenGeneralErrorText)
            }
        }

        viewModel.requestError.bind { [weak self] error in
            switch error {
                case .invalidToken:
                    self?.navigationDelegate?.navigateTo(step: .register)
                case .tooManyRequests(let repeatAfterSeconds):
                    var message = Constants.Strings.healthStatusTooManyRequestsErrorText + " "
                    let hours = repeatAfterSeconds / 3600
                    if hours > 0 {
                        message += ("\(hours) " + Constants.Strings.dateFormatHours)
                    }
                    let minutes = repeatAfterSeconds / 60
                    if minutes > 0 {
                        message += ("\(minutes) " + Constants.Strings.dateFormatMinutes)
                    }
                    if hours == 0 && minutes == 0 {
                        message += Constants.Strings.dateFormatLittleMoreTime
                    }
                    let alert = UIAlertController(title: nil,
                                                  message: message,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Constants.Strings.genaralAgreedText,
                                                  style: .default,
                                                  handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                case .server, .general:
                    self?.showToast(message: Constants.Strings.healthStatusUnknownErrorText)
            }
        }

        // fired only on success
        viewModel.isSendAnswersCompleted.bind { [weak self] result in
            self?.navigationDelegate?.navigateTo(step: .home)
        }
    }
    
    // MARK: Actions
    
    @IBAction private func didTapSubmitButton(_ sender: Any) {
        // TODO: Validation - lenght
        viewModel.didTapPersonalNumberAuthorization(with: egnTextField.text ?? "")
    }

    @IBAction private func didTapSkipButton(_ sender: Any) {
        viewModel.didTapSkipButton()
    }
    
}

// MARK: ToastViewPresentable

extension EGNViewController: ToastViewPresentable {}

// MARK: UITextFieldDelegate

extension EGNViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maximumPersonalNumberLength
    }
}
