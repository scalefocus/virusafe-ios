//
//  SubmitTableViewCell.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class SubmitTableViewCell: UITableViewCell, Configurable {
    
    private var didTabSubmitAction: (() -> Void)?
    
    func configureWith(_ data: @escaping (() -> Void)) {
        self.didTabSubmitAction = data
    }
    
    
    @IBAction func didTapSubmitButton(_ sender: Any) {
        didTabSubmitAction?()
    }
}
