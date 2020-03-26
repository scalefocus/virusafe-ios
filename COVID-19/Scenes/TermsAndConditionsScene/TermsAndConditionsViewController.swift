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
        loadTnCFromRtf()
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

    private func loadTnCFromRtf() {
        if let rtfPath = Bundle.main.url(forResource: "TnC", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                // TODO: Refactor to avoid this side effect
                self.contentTextView.attributedText = attributedStringWithRtf
            } catch let error {
                // TODO: Handle error
                print("Got an error \(error)")
            }
        }
    }

}

