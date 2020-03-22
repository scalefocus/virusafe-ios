//
//  ViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var wrapperViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var confirmButton: UIButton!
    private let viewModel = RegistrationViewModel(repository: RegistrationRepository())
    private let phoneNumberMaxLength = 15
    private var isKeyboardUp = false
    @IBOutlet private weak var confirmButtonBottomConstraint: NSLayoutConstraint!
    
    private struct LocalConstants {
        static let buttonBottomConstraintSize: CGFloat = 30
        static let confirmButtonMinTopMargin: CGFloat = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        logoImageView.tintColor = .healthBlue
        phoneNumberTextField.borderStyle = .none
        addKeyboardNotifications()
        hideKeyboardWhenTappedAround()
        confirmButton.backgroundColor = .healthBlue
        
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
                let registrationConfirmationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(RegistrationConfirmationViewController.self)")
                strongSelf.navigationController?.pushViewController(registrationConfirmationVC,
                                                                    animated: true)
            } else {
                // TODO: Show popup that something is wrong
            }
        }
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: Keyboard actions
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
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
            
            // If there's enough space on screen to show everything, we move up just the "Confirm" Button. Else we move up the whole view
            if errorLabel.frame.maxY < UIScreen.main.bounds.height - keyboardHeight - confirmButton.frame.height - LocalConstants.buttonBottomConstraintSize - LocalConstants.confirmButtonMinTopMargin {
                confirmButtonBottomConstraint.constant += keyboardHeight - LocalConstants.buttonBottomConstraintSize
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
        confirmButtonBottomConstraint.constant = 45
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
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

extension RegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= phoneNumberMaxLength
    }
}
