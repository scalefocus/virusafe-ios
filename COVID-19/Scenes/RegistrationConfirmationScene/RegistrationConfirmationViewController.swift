//
//  RegistrationConfirmationViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RegistrationConfirmationViewController: UIViewController {
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    private let verificationCodeWidth: CGFloat = 20
    private let verificationCodeHeight: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Верификация"
        verificationCodeTextField.withImage(UIImage(named: "unlocked_keylock"),
                                            direction: .right,
                                            rect: CGRect(x: 0,
                                                         y: verificationCodeHeight / 2,
                                                         width: verificationCodeWidth,
                                                         height: verificationCodeHeight))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        verificationCodeTextField.becomeFirstResponder()
    }

    @IBAction func didTapEditButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(HomeViewController.self)")
        let navigationController = UINavigationController(rootViewController: homeViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }
}
