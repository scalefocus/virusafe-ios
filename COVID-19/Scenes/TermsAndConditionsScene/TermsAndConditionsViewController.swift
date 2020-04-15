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
        title = "terms_n_conditions_label".localized()
        acceptButton.setTitle("i_agree_label".localized(), for: .normal)
    }

    private func loadHtmlFormat() {
        DispatchQueue.global(qos: .userInitiated).async {
            let text = "tnc_part_one".localized() + "tnc_part_two".localized()

            guard let attributedHTMLString = text.htmlToAttributedString else {
                return
            }
            // Try add Bigger font
            let attributedText = NSMutableAttributedString(attributedString: attributedHTMLString)

            attributedText.enumerateAttribute(
                NSAttributedString.Key.font,
                in: NSMakeRange(0, attributedText.length),
                options:.longestEffectiveRangeNotRequired) { value, range, stop in
                    let f1 = value as! UIFont
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

    private func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
        let t = f1.fontDescriptor.symbolicTraits
        if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
            return UIFont.init(descriptor: fd, size: 0)
        }
        return nil
    }

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
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
