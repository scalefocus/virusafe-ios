//
//  NoSymptomsTableViewCell.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class NoSymptomsTableViewCell: UITableViewCell, Configurable {
    
    @IBOutlet weak var checkBoxImageView: UIImageView!
    var isCheckBoxSelected: Bool = false
    var didTapCheckBoxCallback: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapCheckBox))
        checkBoxImageView.addGestureRecognizer(tap)
    }
    
    func configureWith(_ data: NoSymptomsCellModel) {
        selectImage(hasSymptoms: data.hasSymptoms)
        self.didTapCheckBoxCallback = data.didTapCheckBox
    }
    
    @objc func didTapCheckBox() {
        isCheckBoxSelected.toggle()
        didTapCheckBoxCallback?(isCheckBoxSelected)
        selectImage(hasSymptoms: isCheckBoxSelected)
    }
    
    private func selectImage(hasSymptoms: Bool) {
        checkBoxImageView.image = isCheckBoxSelected ?
        UIImage(named: "ic_checkbox_on")?.withRenderingMode(.alwaysTemplate)
        : UIImage(named: "ic_checkbox_off")?.withRenderingMode(.alwaysTemplate)
    }
    
}

struct NoSymptomsCellModel {
    let hasSymptoms: Bool
    let didTapCheckBox: (Bool) -> Void
}
