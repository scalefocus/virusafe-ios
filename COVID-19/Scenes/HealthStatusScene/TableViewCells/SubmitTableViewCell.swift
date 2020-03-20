//
//  SubmitTableViewCell.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class SubmitTableViewCell: UITableViewCell, Configurable {
    
    @IBOutlet private weak var submitButton: UIButton!
    private var didTabSubmitAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        submitButton.backgroundColor = .healthBlue
        submitButton.layer.borderColor = UIColor.healthBlue?.cgColor
    }
    
    func configureWith(_ data: @escaping (() -> Void)) {
        self.didTabSubmitAction = data
    }
    
    
    @IBAction private func didTapSubmitButton(_ sender: Any) {
        didTabSubmitAction?()
    }
}
