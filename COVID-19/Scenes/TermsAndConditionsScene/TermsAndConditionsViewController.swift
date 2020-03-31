//
//  TermsAndConditionsViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

typealias TNCUserResponseHandler = () -> Void

class TermsAndConditionsViewController: UIViewController {

    var userResponseHandler: TNCUserResponseHandler?

    // MARK: Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var acceptButton: UIButton!

    // MARK: Actions

    @IBAction private func acceptButtonTap() {
        viewModel.repository.isAgree = true
        userResponseHandler?()
    }

    // MARK: ViewModel

    var viewModel: TermsAndConditionsViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptButton.isHidden = viewModel.repository.isAgree
        loadTnCFromRtf()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentTextView.setContentOffset(.zero, animated: false)
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        // TODO: Others
        // !!! Other colors & fonts are set in the storyboard
    }

    private func localize() {
        title = "terms_n_conditions_label".localized()
        titleLabel.text = "terms_n_conditions_label".localized()
        acceptButton.setTitle("i_agree_label".localized(), for: .normal)
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
