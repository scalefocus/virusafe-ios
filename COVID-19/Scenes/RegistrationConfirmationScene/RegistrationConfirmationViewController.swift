//
//  RegistrationConfirmationViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RegistrationConfirmationViewController: UIViewController {

    // MARK: Constants

    private let verificationCodeWidth: CGFloat = 20
    private let verificationCodeHeight: CGFloat = 20
    private let maximumValidationCodeLength = 6
    private var isKeyboardUp = false
    
    private struct LocalConstants {
        static let buttonBottomConstraintSize: CGFloat = 20
        static let confirmButtonMinTopMargin: CGFloat = 5
    }

    // MARK: Outlets
    
    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            let userShieldIcon = #imageLiteral(resourceName: "user-shield").withRenderingMode(.alwaysTemplate)
            iconImageView.image = userShieldIcon
            iconImageView.tintColor = .healthBlue
        }
    }
    @IBOutlet private weak var newCodeBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var wrapperViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var verificationCodeTextField: UITextField!

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var mobileNumberLabel: UILabel!

    // MARK: View Model

    // Injected from parent in order to get its instance of the RegistrationRepository
    var viewModel: RegistrationConfirmationViewModel!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Верификация"
        verificationCodeTextField.borderStyle = .none
        confirmButton.backgroundColor = .healthBlue
        hideKeyboardWhenTappedAround()
        addKeyboardNotifications()
        
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                strongSelf.verificationCodeTextField.resignFirstResponder()
                LoadingIndicatorManager.startActivityIndicator(.whiteLarge,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }
        
        viewModel.isRequestSuccessful.bind { [weak self] isRequestSuccessful in
            guard let strongSelf = self else { return }
            
            if isRequestSuccessful {
                strongSelf.showHomeModule()
            } else {
                // TODO: Show popup that something is wrong
            }
        }

        mobileNumberLabel.text = "Телефон: \(viewModel.mobileNumber())" 
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        verificationCodeTextField.resignFirstResponder()
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, !isKeyboardUp {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            if errorLabel.frame.maxY < UIScreen.main.bounds.height - keyboardHeight - confirmButton.frame.height - LocalConstants.buttonBottomConstraintSize - LocalConstants.confirmButtonMinTopMargin {
                newCodeBottomConstraint.constant += keyboardHeight - 45
            } else {
                wrapperViewTopConstraint.constant = -keyboardHeight
            }
            isKeyboardUp = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        isKeyboardUp = false
        wrapperViewTopConstraint.constant = 0
        newCodeBottomConstraint.constant = 45
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    private func showHomeModule() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(HomeViewController.self)")
        let navigationController = UINavigationController(rootViewController: homeViewController)
        keyWindow.rootViewController = navigationController
        UserDefaults.standard.set(true, forKey: "isUserRegistered")
        
        UIView.transition(with: keyWindow,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

//    @IBAction private func didTapEditButton(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
    
    @IBAction private func didTapConfirmButton(_ sender: Any) {
        guard let authorizationCode = verificationCodeTextField.text else { return }
        
        if authorizationCode.count < 6 {
            errorLabel.isHidden = false
            errorLabel.text = "Невалидна дължина"
            return
        } else if !authorizationCode.isDigitsOnly {
            errorLabel.isHidden = false
            errorLabel.text = "Невалиден формат"
            return
        } else {
            errorLabel.isHidden = true
            viewModel.didTapCodeAuthorization(with: authorizationCode)
        }
    }
    
}

extension RegistrationConfirmationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maximumValidationCodeLength
    }
}
