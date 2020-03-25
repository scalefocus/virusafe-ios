//
//  ConfirmationViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

final class ConfirmationViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: Actions

    @IBAction private func backButtonTap() {
        navigateBackToHome()
    }

    // MARK: ViewModel

    private let viewModel = ConfirmationViewModel()

    // MARK: Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestLocationServicesAutorization()
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        tintCheckIcon()
        // !!! Other colors & fonts are set in the storyboard
    }

    private func localize() {
        title = "Готово!"
        titleLabel.text = "Готово!"
        textLabel.text = "Благодарим Ви, че сте отговорни!"
        backButton.setTitle("Назад", for: .normal)
    }

    private func tintCheckIcon() {
        let checkIcon = #imageLiteral(resourceName: "check-circle-light").withRenderingMode(.alwaysTemplate)
        iconImageView.image = checkIcon
        iconImageView.tintColor = #colorLiteral(red: 60 / 255, green: 140 / 255, blue: 231 / 255, alpha: 1.0) // Editor representation does't look correct, however it works on device
    }

    // MARK: Setup Binding

    private func setupBinding() {
        // TODO: Add Bindings here
    }

    // MARK: Navigation

    private func navigateBackToHome() {
        
        navigationController?.popToRootViewController(animated: true)
    }

}
