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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        logoImageView.tintColor = .healthBlue
        phoneNumberTextField.borderStyle = .none
        addKeyboardNotifications()
//        confirmButtonState(shouldBeClickable: false)
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
//                strongSelf.phoneNumberTextField.becomeFirstResponder()
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
    
    // MARK: Keyboard actions
    
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
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
//            mostBottomScrollViewConstraint.constant = keyboardHeight + additionalKeyboardHeight
            wrapperViewTopConstraint.constant = -keyboardHeight
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {

        wrapperViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
//        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func confirmButtonState(shouldBeClickable: Bool) {
        confirmButton.isEnabled = shouldBeClickable
        confirmButton.setTitleColor(shouldBeClickable ? .black : .gray, for: .normal)
    }
    
    @IBAction private func didTapRegisterButton(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text else { return }
        viewModel.didTapRegistration(with: phoneNumber)
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        confirmButtonState(shouldBeClickable: !(0...3).contains(newString.length))
        
        return newString.length <= phoneNumberMaxLength
    }
}


extension UIViewController {
    
    /// Hides the keyboard when tapped anywhere on the screen
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
           if touch.view is UIButton {
               return false
           }
           return true
       }
}
