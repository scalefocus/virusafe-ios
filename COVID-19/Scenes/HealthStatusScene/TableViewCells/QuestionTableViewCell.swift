//
//  QuestionTableViewCell.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell, Configurable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var didTapButton: ((Bool) -> Void)?
    
    func configureWith(_ data: QuestionCellModel) {
        titleLabel.text = data.title
        didTapButton(isActiveState: data.isSymptomActive)
        self.didTapButton = data.didTapButton
    }
    
    @IBAction func didTapYesButton(_ sender: Any) {
        didTapButton(isActiveState: true)
        self.didTapButton?(true)
    }
    
    @IBAction func didTapNoButton(_ sender: Any) {
        didTapButton(isActiveState: false)
        self.didTapButton?(false)
    }
    
    func didTapButton(isActiveState: Bool?) {
        guard let isActiveState = isActiveState else {
            yesButton.backgroundColor =  .white
            yesButton.setTitleColor(.black, for: .normal)
            noButton.backgroundColor =  .white
            noButton.setTitleColor(.black, for: .normal)
            return
        }
        yesButton.backgroundColor = isActiveState ? .blue : .white
        yesButton.setTitleColor(isActiveState ? .white : .black, for: .normal)
        noButton.backgroundColor = isActiveState ? .white : .blue
        noButton.setTitleColor(isActiveState ? .black : .white, for: .normal)
    }
}

struct QuestionCellModel {
    let index: Int
    let title: String
    var isSymptomActive: Bool?
    var didTapButton: (Bool) -> Void
}
