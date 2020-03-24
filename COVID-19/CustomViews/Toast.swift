//
//  Toast.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

final class ToastView: UIView {
    fileprivate lazy var toastLabel: UILabel = {
        let toastLabel = UILabel(frame: self.bounds)
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        return toastLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        addSubview(toastLabel)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            toastLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            toastLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = toastLabel.intrinsicContentSize
        return CGSize(width: labelSize.width + 32, height: labelSize.height + 16)
    }

}

protocol ToastViewPresentable {
    func showToast(message : String)
}

extension ToastViewPresentable where Self: UIViewController {
    func showToast(message : String) {
        let toastView = ToastView(frame: .zero)
        toastView.toastLabel.text = message
        toastView.alpha = 0.0
        toastView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(toastView)

        NSLayoutConstraint.activate([
            toastView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -32),
            toastView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 24),
            toastView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -24)
        ])

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 3.0, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: {_ in
                toastView.removeFromSuperview()
            })
        })
    }
}
