//
//  TermsAndConditionsViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

typealias TNCUserResponseHandler = () -> Void

enum TermsScreenType {
    case termsAndConditions
    case processPersonalData
}

class TermsAndConditionsViewController: UIViewController {

    var userResponseHandler: TNCUserResponseHandler?
    var termsScreenType: TermsScreenType = .termsAndConditions

    // MARK: Outlets
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var acceptButton: UIButton!

    // MARK: Actions

    @IBAction private func acceptButtonTap() {
        switch termsScreenType {
        case .termsAndConditions:
            viewModel.repository.isAgree = true
            userResponseHandler?()
        case .processPersonalData:
            viewModel.repository.isAgreeDataProtection = true
            userResponseHandler?()
        }
    }

    // MARK: ViewModel

    var viewModel: TermsAndConditionsViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        switch termsScreenType {
        case .termsAndConditions:
            acceptButton.isHidden = viewModel.repository.isAgree
        case .processPersonalData:
            acceptButton.isHidden = viewModel.repository.isAgreeDataProtection
        }
        contentTextView.textContainerInset = UIEdgeInsets(top: 24,
                                                          left: 24,
                                                          bottom: 24,
                                                          right: 24)
        loadHtmlFormat()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    // MARK: Setup UI

    private func setupUI() {
        localize()
        // TODO: Others
        // !!! Other colors & fonts are set in the storyboard
    }

    private func localize() {
        switch termsScreenType {
        case .termsAndConditions:
            title = "terms_n_conditions_label".localized()
        case .processPersonalData:
            title = "dpn_title_short".localized()
        }

        acceptButton.setTitle("i_agree_label".localized(), for: .normal)
    }

    private func loadHtmlFormat() {
        DispatchQueue.global(qos: .userInitiated).async {
            var text = ""
            switch self.termsScreenType {
            case .termsAndConditions:
                text = "tnc_part_one".localized() + "tnc_part_two".localized()
            case .processPersonalData:
                text = "dpn_description".localized()
            }

            guard let attributedHTMLString = text.htmlToAttributedString else {
                return
            }
            // Try add Bigger font
            let attributedText = NSMutableAttributedString(attributedString: attributedHTMLString)

            attributedText.enumerateAttribute(
                NSAttributedString.Key.font,
                in: NSRange(location: 0, length: attributedText.length),
                options: .longestEffectiveRangeNotRequired) { value, range, _ in
                    guard let f1 = value as? UIFont else { return }
                    let f2 = UIFont.systemFont(ofSize: 16)
                    if let f3 = self.applyTraitsFromFont(f1, to: f2) {
                        attributedText.addAttribute(
                            NSAttributedString.Key.font, value: f3, range: range
                        )
                    }
            }

            DispatchQueue.main.async {
                self.contentTextView.setContentOffset(.zero, animated: false)
                self.contentTextView.attributedText = attributedText
            }
        }
    }

    private func applyTraitsFromFont(_ firstFont: UIFont, to secondFont: UIFont) -> UIFont? {
        let traits = firstFont.fontDescriptor.symbolicTraits
        if let fontDescriptor = secondFont.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont.init(descriptor: fontDescriptor, size: 0)
        }
        return nil
    }

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

final class HairlineConstraint: NSLayoutConstraint {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.constant = 1.0 / UIScreen.main.scale
    }
}
