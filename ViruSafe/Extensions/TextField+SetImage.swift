//
//  TextField+SetImage.swift
//  ViruSafe
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

extension UITextField {
    
    /// Defines the possible places where image could be set
    enum Direction {
        case left
        case right
    }
    
    /// Sets left / right image to the TextField
    /// - Parameters:
    ///   - image: Optional. The image which is going to be set on the left or right.
    ///   - direction: .left or .right on the TextField.
    ///   - rect: The frame of the image view.
    ///   - tintColor: Optional. The color of the image.
    ///   - viewMode: TextField View Mode. Default is .always
    func withImage(_ image: UIImage?,
                   direction: Direction,
                   rect: CGRect,
                   tintColor: UIColor? = nil,
                   viewMode: UITextField.ViewMode = .always) {
        
        let additionalImagePadding: CGFloat = 10
        let containerView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: rect.width + additionalImagePadding,
                                                 height: bounds.height))
        containerView.clipsToBounds = true
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor
        imageView.frame = rect
        containerView.addSubview(imageView)
        
        switch direction {
        case .left:
            leftViewMode = viewMode
            leftView = containerView
        case .right:
            rightViewMode = viewMode
            rightView = containerView
        }
    }

}

