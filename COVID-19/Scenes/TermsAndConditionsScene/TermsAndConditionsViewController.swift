//
//  TermsAndConditionsViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

typealias TNCUserResponseHandler = (Bool) -> Void

class TermsAndConditionsViewController: UIViewController {

    var userResponseHandler: TNCUserResponseHandler?

    // MARK: Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var acceptButton: UIButton!

    // MARK: Actions

    @IBAction private func acceptButtonTap() {
        userResponseHandler?(true)
    }

    // MARK: ViewModel

    var viewModel: TermsAndConditionsViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        acceptButton.isHidden = !viewModel.isAcceptButtonVisible
        // TODO: Load terms and conditions to TextView
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        // TODO: Others
        // !!! Other colors & fonts are set in the storyboard
    }

    private func localize() {
        titleLabel.text = "Условия за ползване"
        acceptButton.setTitle("Съгласен съм", for: .normal)
    }

}
