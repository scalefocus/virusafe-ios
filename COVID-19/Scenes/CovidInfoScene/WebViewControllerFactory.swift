//
//  WebViewControllerFactory.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

extension WebViewController {
    static func show(with source: Source) {
        // Create Controller
        guard let webViewController = UIStoryboard(name: "WebView", bundle: nil)
            .instantiateViewController(withIdentifier: "\(WebViewController.self)")
            as? WebViewController else {
                assertionFailure("WebViewController is not found")
                return
        }

        if #available(iOS 13.0, *) {
            webViewController.isModalInPresentation = true // available in IOS13
        }
        webViewController.edgesForExtendedLayout = []

        // Add it as root in navigation controller
        let navigationController = UINavigationController(rootViewController: webViewController)

        // Add Close Button
        let leftBarButtonItem = UIBarButtonItem.init(title: "Назад", style: .done) { [weak navigationController] _ in
             navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        webViewController.navigationItem.leftBarButtonItem = leftBarButtonItem

        if #available(iOS 13.0, *) {
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(navigationController, animated: true) {
                    webViewController.load(source: source)
                }
            }
        } else {
            // Root for this window
            let rootViewController = UIViewController()
            rootViewController.view.backgroundColor = .clear

            // Create New Window
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = rootViewController
            window.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
            window.makeKeyAndVisible()

            // present (a little headache)
            rootViewController.present(navigationController, animated: true) {
                webViewController.load(source: source)
            }
        }

    }
}

// MARK: Helper - Add Closure to UIBarButtonItem

extension UIBarButtonItem {
    typealias UIBarButtonItemTargetClosure = (UIBarButtonItem) -> ()

    private class UIBarButtonItemClosureWrapper: NSObject {
        let closure: UIBarButtonItemTargetClosure
        init(_ closure: @escaping UIBarButtonItemTargetClosure) {
            self.closure = closure
        }
    }

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: UIBarButtonItemTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIBarButtonItemClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIBarButtonItemClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, closure: @escaping UIBarButtonItemTargetClosure) {
        self.init(title: title, style: style, target: nil, action: nil)
        targetClosure = closure
        action = #selector(UIBarButtonItem.closureAction)
    }

    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}
