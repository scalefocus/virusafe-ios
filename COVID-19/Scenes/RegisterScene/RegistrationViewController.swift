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
    private let phoneNumberMaxLength = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        confirmButtonState(shouldBeClickable: false)
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
        let registrationConfirmationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(RegistrationConfirmationViewController.self)")
        navigationController?.pushViewController(registrationConfirmationVC, animated: true)
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        confirmButtonState(shouldBeClickable: !(0...7).contains(newString.length))
        
        return newString.length <= phoneNumberMaxLength
    }
}

