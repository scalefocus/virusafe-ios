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
}

protocol RegistrationRepositoryProtocol {
    func authoriseMobileNumber(mobileNumber: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func sendPersonalInfo(personalNumberNumber: String, age: Int, gender: String, preexistingConditions: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
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
    
    func authoriseVerificationCode(verificationCode: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        guard let mobileNumber = authorisedMobileNumber else {
            assertionFailure("Authorised mobile number not found")
            completion(.invalidPin)
            return
        }

        TokenApiRequest(phoneNumber: mobileNumber, pin: verificationCode).executeParsed(of: ApiToken.self) { (parsedData, response, error) in
            guard response?.statusCode != 438 else {
                completion(.invalidPhoneNumber)
                return
            }

            guard let parsedData = parsedData, error == nil else {
                completion(.generalError)
                return
            }
            // Store it
            TokenStore.shared.token = parsedData.accessToken
            // Update manager
            APIManager.shared.authToken = parsedData.accessToken
            completion(.success)
        }
    }
    
    func sendPersonalInfo(personalNumberNumber: String, age: Int, gender: String, preexistingConditions: String, completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
            let request = PersonalNumerApiRequest(bodyJSONObject: ["identificationNumber": personalNumberNumber, "age": "\(age)", "gender": gender, "preExistingConditions": preexistingConditions])
                
            request.execute { (_, response, error) in
                guard response?.statusCode != 412 else {
                    completion(.invalidPersonalNumber)
                    return
                }

                guard error == nil else {
                    completion(.generalError)
                    return
                }
        
                
                completion(.success)
            }
        }
    
    func getPersonalInfo(completion: @escaping ((PersonalInformation) -> Void)) {
        GetPersonalInfoRequest().executeParsed(of: PersonalInformation.self) { (personalInformation, response, error) in
            if let personalInformation = personalInformation {
                completion(personalInformation)
            }
        }
    }
}

