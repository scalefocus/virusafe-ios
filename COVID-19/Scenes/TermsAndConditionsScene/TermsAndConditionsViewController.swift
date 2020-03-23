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

    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var toolbarView: UIView!
    @IBOutlet private weak var declineButton: UIButton!
    @IBOutlet private weak var acceptButton: UIButton!

    // MARK: Actions

    @IBAction private func declineButtonTap() {
        userResponseHandler?(false)
    }

    @IBAction private func acceptButtonTap() {
        userResponseHandler?(false)
    }

    // MARK: ViewModel

    private let viewModel = TermsAndConditionsViewModel()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        viewModel.setup()
        // TODO: Load terms and conditions to TextView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupContentTextViewInsets()
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        // TODO: Others
        // !!! Other colors & fonts are set in the storyboard
    }

    private func setupContentTextViewInsets() {
        let inset = UIEdgeInsets(top: 0,
                                 left: 0,
                                 bottom: toolbarView.frame.height,
                                 right: 0)
        contentTextView.contentInset = inset
        contentTextView.scrollIndicatorInsets = inset
    }

    private func localize() {
        title = "Условия за ползване"
        titleLabel.text = "Условия за ползване"
        declineButton.setTitle("Отказвам", for: .normal)
        acceptButton.setTitle("Съгласен съм", for: .normal)
    }

    // MARK: Setup Binding

    private func setupBinding() {
        viewModel.isDeclineButtonVisible.bind { [weak self] value in
            self?.declineButton.isHidden = !value
        }
    }

}
