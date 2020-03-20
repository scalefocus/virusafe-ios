//
//  ViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

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
        confirmButtonState(shouldBeClickable: false)
        
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                strongSelf.phoneNumberTextField.resignFirstResponder()
                LoadingIndicatorManager.startActivityIndicator(.whiteLarge,
                                                               in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
                strongSelf.phoneNumberTextField.becomeFirstResponder()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        phoneNumberTextField.becomeFirstResponder()
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

