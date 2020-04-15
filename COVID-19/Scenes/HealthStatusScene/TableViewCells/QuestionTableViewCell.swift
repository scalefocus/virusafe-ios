//
//  QuestionTableViewCell.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell, Configurable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var didTapButton: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        yesButton.layer.borderColor = UIColor.healthBlue?.cgColor
        noButton.layer.borderColor = UIColor.healthBlue?.cgColor
        yesButton.setTitleColor(.healthBlue, for: .normal)
        noButton.setTitleColor(.healthBlue, for: .normal)
        
        yesButton.setTitle("yes_label".localized(), for: .normal)
        noButton.setTitle("no_label".localized(), for: .normal)
    }
    
    func configureWith(_ data: QuestionCellModel) {
        titleLabel.text = data.title
        didTapButton(isActiveState: data.isSymptomActive)
        self.didTapButton = data.didTapButton
    }
    
    @IBAction private func didTapYesButton(_ sender: Any) {
        didTapButton(isActiveState: true)
        self.didTapButton?(true)
    }
    
    @IBAction private func didTapNoButton(_ sender: Any) {
        didTapButton(isActiveState: false)
        self.didTapButton?(false)
    }
    
    private func didTapButton(isActiveState: Bool?) {
        guard let isActiveState = isActiveState else {
            yesButton.backgroundColor = .white
            yesButton.setTitleColor(.healthBlue, for: .normal)
            noButton.backgroundColor =  .white
            noButton.setTitleColor(.healthBlue, for: .normal)
            return
        }
        yesButton.backgroundColor = isActiveState ? .healthBlue : .white
        yesButton.setTitleColor(isActiveState ? .white : .healthBlue, for: .normal)
        noButton.backgroundColor = isActiveState ? .white : .healthBlue
        noButton.setTitleColor(isActiveState ? .healthBlue : .white, for: .normal)
    }
}

struct QuestionCellModel {
    let index: Int
    let title: String
    var isSymptomActive: Bool?
    var didTapButton: (Bool) -> Void
}
