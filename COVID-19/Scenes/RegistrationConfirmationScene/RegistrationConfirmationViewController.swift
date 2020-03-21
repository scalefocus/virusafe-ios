//
//  RegistrationConfirmationViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RegistrationConfirmationViewController: UIViewController {
    
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var verificationCodeTextField: UITextField!
    private let viewModel = RegistrationConfirmationViewModel(repository: RegistrationRepository())
    private let verificationCodeWidth: CGFloat = 20
    private let verificationCodeHeight: CGFloat = 20
    private let maximumValidationCodeLength = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Верификация"
        verificationCodeTextField.withImage(UIImage(named: "unlocked_keylock"),
                                            direction: .right,
                                            rect: CGRect(x: 0,
                                                         y: verificationCodeHeight / 2,
                                                         width: verificationCodeWidth,
                                                         height: verificationCodeHeight))
        confirmButtonState(shouldBeClickable: false)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        verificationCodeTextField.becomeFirstResponder()
    }
    
    private func confirmButtonState(shouldBeClickable: Bool) {
        confirmButton.isEnabled = shouldBeClickable
        confirmButton.setTitleColor(shouldBeClickable ? .black : .gray, for: .normal)
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

    @IBAction private func didTapEditButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapConfirmButton(_ sender: Any) {
        guard let authorizationCode = verificationCodeTextField.text else { return }
        viewModel.didTapCodeAuthorization(with: authorizationCode)
    }
    
}

extension RegistrationConfirmationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        confirmButtonState(shouldBeClickable: !(0...5).contains(newString.length))
        
        return newString.length <= maximumValidationCodeLength
    }
}
