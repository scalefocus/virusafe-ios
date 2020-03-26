//
//  ApiErrorHandler.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 26.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

//enum ApiErrorCode: Int {
//    case invalidToken = 403
//    case preconditionFailed = 412
//    case tooManyRequests = 429
//}
//
//final class ApiErrorHandler {
//
//    func handle(errorCode: Int) {
//        switch errorCode {
//        case ApiErrorCode.invalidToken.rawValue:
//            // clear token
//            TokenStore.shared.token = nil
//            // try to navigate registration screen
//            guard let keyWindow = UIApplication.shared.keyWindow else {
//                return
//            }
//            let registrationViewController =
//                UIStoryboard(name: "Main", bundle: nil)
//                    .instantiateViewController(withIdentifier: "\(RegistrationViewController.self)")
//            let navigationController = UINavigationController(rootViewController: registrationViewController)
//            keyWindow.rootViewController = navigationController
//            UIView.transition(with: keyWindow,
//                              duration: 0.5,
//                              options: .transitionCrossDissolve,
//                              animations: nil,
//                              completion: nil)
//        case ApiErrorCode.preconditionFailed.rawValue:
//            <#code#>
//        case ApiErrorCode.tooManyRequests.rawValue:
//            <#code#>
//        default:
//            // TODO: Something
//            break
//        }
//    }
//
//
//}
