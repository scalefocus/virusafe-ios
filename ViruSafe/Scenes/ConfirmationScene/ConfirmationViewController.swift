//
//  ConfirmationViewController.swift
//  ViruSafe
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

final class ConfirmationViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: Actions

    @IBAction private func backButtonTap() {
        navigationDelegate?.navigateTo(step: .home)
    }

    // MARK: ViewModel

    private let viewModel = ConfirmationViewModel()

    // MARK: Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        tintCheckIcon()
        // !!! Other colors & fonts are set in the storyboard
    }

    private func localize() {
        title = "done_title".localized()
        titleLabel.text = "done_title".localized()
        textLabel.text = "done_msg".localized()
        backButton.setTitle("continue_label".localized(), for: .normal)
    }

    private func tintCheckIcon() {
        let checkIcon = #imageLiteral(resourceName: "check-circle-light").withRenderingMode(.alwaysTemplate)
        iconImageView.image = checkIcon
        iconImageView.tintColor = #colorLiteral(red: 60 / 255, green: 140 / 255, blue: 231 / 255, alpha: 1.0) // Editor representation does't look correct, however it works on device
    }

}
