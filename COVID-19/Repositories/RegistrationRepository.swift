//
//  RegistrationRepository.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

enum AuthoriseMobileNumberResult {
    case success
    case invalidPhoneNumber
    case invalidPin
    case invalidPersonalNumber
    case generalError
    case tooManyRequests(reapeatAfter: Int) // Seconds
}

protocol RegistrationRepositoryProtocol {
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func registerPushToken(_ pushToken: String, completion: @escaping ((ApiResult<Void>) -> Void))
}

class RegistrationRepository: RegistrationRepositoryProtocol {

    private (set) var authorisedMobileNumber: String?
    
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        PinApiRequest(phoneNumber: mobileNumber).execute { [weak self] (data, response, error) in
            // Request argument validation has failed
            if response?.statusCode == 412 {
                // No other argument so no special handling
                completion(.invalidPhoneNumber)
                return
            }

            // Request rate limit has been exceeded
            if response?.statusCode == 429 {
                TooManyRequestestHandler().handle(data: data, completion: completion)
                return
            }

            // ??? Change general to server error
            guard response?.statusCode.isSuccess == true else {
                completion(.generalError)
                return
            }

            // network error
            guard error == nil else {
                completion(.generalError)
                return
            }

            self?.authorisedMobileNumber = mobileNumber

            completion(.success)
        }
    }
    
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        guard let mobileNumber = authorisedMobileNumber else {
//            assertionFailure("Authorised mobile number not found")
            completion(.invalidPhoneNumber)
            return
        }

        TokenApiRequest(phoneNumber: mobileNumber, pin: verificationCode).executeParsed(of: ApiToken.self) { (parsedData, response, error) in
            // Request argument validation has failed
            // TODO: Parse result
            if response?.statusCode == 412 {
                // ??? Do we really need this
                completion(.invalidPhoneNumber)
                return
            }

            // Could not verify matching PIN and phone number
            if response?.statusCode == 438 {
                completion(.invalidPin)
                return
            }

            // Request rate limit has been exceeded
            if response?.statusCode == 429 {
                TooManyRequestestHandler().handle(data: nil, completion: completion)
                return
            }

            // ??? Change general to server error
            guard response?.statusCode.isSuccess == true else {
                completion(.generalError)
                return
            }

            // Network error
            guard let parsedData = parsedData, error == nil else {
                completion(.generalError)
                return
            }

            // Store retunerd toke (jwt)
            TokenStore.shared.token = parsedData.accessToken
            // Update manager to auth requests
            APIManager.shared.authToken = parsedData.accessToken

            completion(.success)
        }
    }

    func registerPushToken(_ pushToken: String, completion: @escaping ((ApiResult<Void>) -> Void)) {
        SendPushTokenRequest(pushToken: pushToken).execute { (_, _, error) in
            guard error == nil else {
                completion(.failure(.general))
                return
            }
            completion(.success(Void()))
        }
    }

}

final class TooManyRequestestHandler {
    func handle(data: Data?, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        let reapeatAfter = handle(data: data)
        completion(.tooManyRequests(reapeatAfter: reapeatAfter))
    }

    func handle(data: Data?) -> Int {
        guard let data = data else {
            return Timeout.defaultInSeconds
        }
        guard let paresedData = TooManyRequestsResponseDataParser().parse(data) else {
            return Timeout.defaultInSeconds
        }
        return paresedData.reapeatAfter
    }
}

//final class ArgumentValidationFailedHandler {
//    func handle(data: Data?, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
//        guard let data = data else {
//            completion(.invalidPhoneNumber)
//            return
//        }
//        guard let paresedData = ArgumentValidationFailedParser().parse(data) else {
//            completion(.invalidPhoneNumber)
//            return
//        }
//        completion(.invalidPhoneNumber)
//    }
//}
//
//struct ArgumentValidationFailedParser {
//    func parse(_ data: Data) -> ArgumentValidationFailedResponse? {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return try? decoder.decode(ArgumentValidationFailedResponse.self, from: data)
//    }
//}
//
//struct ArgumentValidationFailedResponse: Codable {
//    var timestamp: String
//    var message: String
//    var cause: String?
//    var validationErrors: [String]
//}
//
//struct ValidationError {
//    var fieldName: String
//    var rejectedValue: [String: Any]
//    var validationMessage: String
//}
