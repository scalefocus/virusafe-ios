//
//  CheckBox.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    // MARK: Settings

    private let checkedImage = #imageLiteral(resourceName: "ic_checkbox_on")
    private let uncheckedImage = #imageLiteral(resourceName: "ic_checkbox_off")

    // MARK: Lifecyce

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    // MARK: Setup

    private func setup() {
        self.setImage(checkedImage, for: .selected)
        self.setImage(uncheckedImage, for: .normal)
    }

}
