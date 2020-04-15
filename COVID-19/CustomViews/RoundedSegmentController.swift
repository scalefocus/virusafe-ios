//
//  RoundedSegmentController.swift
//  COVID-19
//
//  Created by Nadezhda on 7.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class RoundedSegmentController: UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selectedColor = UIColor.healthBlue ?? UIColor.white
        layer.cornerRadius = bounds.height / 2
        layer.borderColor = selectedColor.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        // Segmented control is changed for iOS 13
        // https://medium.com/flawless-app-stories/ios-13-uisegmentedcontrol-3-important-changes-d3a94fdd6763
        if #available(iOS 13.0, *) {
            var segmentImageSubviews = subviews.filter { $0.isKind(of: UIImageView.self) }
            segmentImageSubviews.removeLast()
            segmentImageSubviews.enumerated().forEach { subview in
                if subview.offset == selectedSegmentIndex {
                    subview.element.backgroundColor = selectedColor
                    subview.element.cornerRadius = bounds.height / 2
                } else {
                    subview.element.backgroundColor = .clear
                }
                
            }
            
            setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .normal)
        }
    }
}
