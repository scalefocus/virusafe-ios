//
//  ApiStatusCodeHandler.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 26.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import NetworkKit

enum ApiStatusCodeError {
    case invalidToken
    case tooManyRequests
    case badStatusCode
}

enum ApiStatusCodeResult {
    case succes
    case failure(ApiStatusCodeError)
}

final class ApiStatusCodeHandler {
    static func handle(statusCode: Int) -> ApiStatusCodeResult {
        // if in range 200...299
        guard !statusCode.isSuccess else {
            return .succes
        }
        // !!! we expect codes to be in range 400...599
        switch statusCode {
        case 403:
            // clear token
            TokenStore.shared.token = nil
            // try to navigate registration screen
            forceNavigateToRegistrationViewController()
            // return error
            return .failure(.invalidToken)
        case 429:
            return .failure(.tooManyRequests)
        default:
            return .failure(.badStatusCode)
        }
    }

    private static func forceNavigateToRegistrationViewController() {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let registrationViewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(RegistrationViewController.self)")
        let navigationController = UINavigationController(rootViewController: registrationViewController)
        keyWindow.rootViewController = navigationController
        UIView.transition(with: keyWindow,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

}

struct TooManyRequestsResponse: Codable {
    var timestamp: String
    var message: String
    var cause: String?
    var errors: [String]
}
