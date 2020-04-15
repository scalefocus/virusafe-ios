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
    case invalidEgnOrIdNumber
}

enum ApiStatusCodeResult {
    case success
    case failure(ApiStatusCodeError)
}

final class ApiStatusCodeHandler {
    static func handle(statusCode: Int) -> ApiStatusCodeResult {
        // if in range 200...299
        guard !statusCode.isSuccess else {
            return .success
        }
        // !!! we expect codes to be in range 400...599
        switch statusCode {
            case 403: // access forbiden
                // clear token
                TokenStore.shared.token = nil
                // return error
                return .failure(.invalidToken)
            case 412: // Request argument validation has failed
                return .failure(.invalidEgnOrIdNumber)
            case 429: // Request rate limit has been exceeded
                return .failure(.tooManyRequests)
            default:
                return .failure(.badStatusCode)
        }
    }

}
