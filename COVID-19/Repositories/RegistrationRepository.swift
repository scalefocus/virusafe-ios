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
    case generalError
}

protocol RegistrationRepositoryProtocol {
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((Bool) -> Void))
}

class RegistrationRepository: RegistrationRepositoryProtocol {

    private (set) var authorisedMobileNumber: String?
    
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        PinApiRequest(phoneNumber: mobileNumber).execute { [weak self] (_, response, error) in
            guard response?.statusCode != 412 else {
                completion(.invalidPhoneNumber)
                return
            }

            guard error == nil else {
                completion(.generalError)
                return
            }

            self?.authorisedMobileNumber = mobileNumber
            completion(.success)
        }
    }
    
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((Bool) -> Void)) {
        guard let mobileNumber = authorisedMobileNumber else {
            assertionFailure("Authorised mobile number not found")
            completion(false)
            return
        }

        TokenApiRequest(phoneNumber: mobileNumber, pin: verificationCode).executeParsed(of: ApiToken.self) { (parsedData, _, _) in
            guard let parsedData = parsedData else {
                completion(false)
                return
            }
            // Store it
            TokenStore.shared.token = parsedData.accessToken
            // Update manager
            APIManager.shared.authToken = parsedData.accessToken
            completion(true)
        }
    }
    
}

