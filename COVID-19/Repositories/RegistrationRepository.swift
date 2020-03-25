//
//  RegistrationRepository.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

protocol RegistrationRepositoryProtocol {
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((Bool) -> Void))
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((Bool) -> Void))

}

class RegistrationRepository: RegistrationRepositoryProtocol {

    private (set) var authorisedMobileNumber: String?
    
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((Bool) -> Void)) {
        PinApiRequest(phoneNumber: mobileNumber).execute { [weak self] (_, _, error) in
            guard error == nil else {
                completion(false)
                return
            }
            self?.authorisedMobileNumber = mobileNumber
            completion(true)
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

