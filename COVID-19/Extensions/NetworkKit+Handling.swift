//
//  NetworkKit+Handling.swift
//  COVID-19
//
//  Created by Nadezhda on 16.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

extension APIRequest {

    func executeWithHandling(handlesNoNetwork: Bool = true, handlesServerError: Bool = true, completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> Void)) {
        // Inject user agent in headers
        (self as? BaseAPIRequest)?.userAgent = UserAgentBuilder().build()

        execute { (data, response, error) in
            if let response = response,
                response.statusCode == 401 {
                // Status code 401 is received when access token has expired
                if (self.tokenRefreshCount ?? 0) > 0 {
                    // Check if this request is called for the first time
                    APIManager.shared.authToken = nil
                    TokenStore.shared.token = nil
                    print("DEBUG: Access token expired. Refreshing..")
                    // Capture values in case of error
                    let dataCopy = data
                    let responseCopy = response
                    let errorCopy = error
                    // Try to refresh access token.
                    RegistrationRepository().refreshAuthToken(refreshToken: APIManager.shared.refreshToken ?? "") { isSuccessful in
                         // If access token refresh is successful refresh the failed request
                        if isSuccessful {
                            self.executeWithHandling(handlesNoNetwork: handlesNoNetwork,
                                                     handlesServerError: handlesServerError,
                                                     completion: completion)
                        } else {
                            APIManager.shared.refreshToken = nil
                            TokenStore.shared.refreshToken = nil
                            completion(dataCopy, responseCopy, errorCopy)
                        }
                    }
                } else {
                    // Multiple calls on the same request redirect to registration
                    RegistrationRepository().clearAllTokens()
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.flowManager?.redirectToRegistration()
                    completion(data, response, error)
                }
            } else if let response = response, response.statusCode == 403 {
                // Status code 403 is received when refresh token has expired. Redirect to registration
                RegistrationRepository().clearAllTokens()
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.flowManager?.redirectToRegistration()
                completion(data, response, error)
            } else {
                completion(data, response, error)
            }
        }
    }

    func executeParsedWithHandling<T: Codable>(of type: T.Type,
                                               handlesNoNetwork: Bool = true,
                                               handlesServerError: Bool = true,
                                               completion: @escaping ((T?, HTTPURLResponse?, Error?) -> Void)) {
        // Inject user agent in headers
        (self as? BaseAPIRequest)?.userAgent = UserAgentBuilder().build()

        executeParsed(of: T.self) { (data, response, error) in
            // expire access token
            if let response = response,
                response.statusCode == 401 {
                // Status code 401 is received when access token has expired
                if (self.tokenRefreshCount ?? 0) > 0 {
                    // Check if this request is called for the first time
                    APIManager.shared.authToken = nil
                    TokenStore.shared.token = nil
                    print("DEBUG: Access token expired. Refreshing..")
                    // Capture values in case of error
                    let dataCopy = data
                    let responseCopy = response
                    let errorCopy = error
                    // Try to refresh access token.
                    RegistrationRepository().refreshAuthToken(refreshToken: APIManager.shared.refreshToken ?? "") { isSuccessful in
                        // If access token refresh is successful refresh the failed request
                        if isSuccessful {
                            self.executeParsedWithHandling(of: type,
                                                           handlesNoNetwork: handlesNoNetwork,
                                                           handlesServerError: handlesServerError,
                                                           completion: completion)
                        } else {
                            APIManager.shared.refreshToken = nil
                            TokenStore.shared.refreshToken = nil
                            completion(dataCopy, responseCopy, errorCopy)
                        }
                    }
                } else {
                    // Multiple calls on the same request redirect to registration
                    RegistrationRepository().clearAllTokens()
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.flowManager?.redirectToRegistration()
                    completion(data, response, error)
                }
            } else if let response = response, response.statusCode == 403 {
                // Status code 403 is received when refresh token has expired. Redirect to registration
                RegistrationRepository().clearAllTokens()
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.flowManager?.redirectToRegistration()
                completion(data, response, error)
            } else {
                completion(data, response, error)
            }
        }
    }

}

// MARK: Helpers

final class UserAgentBuilder {
    func build() -> String {
        let executable = Bundle.main.applicationDisplayName
        let appVersion = "\(Bundle.main.releaseVersionNumber)(\(Bundle.main.buildVersionNumber))"
        let device = UIDevice.current.modelIdentifier
        let devVersion = UIDevice.current.version
        let darwin = "Darwin/\(UIDevice.current.darwinVersion)"
        let netVersion = networkKitVersion
        return "\(executable)/\(appVersion) \(device) \(devVersion) \(netVersion) \(darwin)"
    }

    private var networkKitVersion: String {
        guard let bundle = Bundle(identifier: "org.cocoapods.NetworkKit") else {
            return "NetworkKit/N/A"
        }
        return "NetworkKit/\(bundle.releaseVersionNumber)(\(bundle.buildVersionNumber))"
    }
}
