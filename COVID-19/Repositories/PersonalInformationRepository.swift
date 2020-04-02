//
//  PersonalInformationRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 29.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

typealias RequestPersonalInformationCompletion = ((ApiResult<PersonalInformation>) -> Void)
typealias SendPersonalInfoCompletion = ((ApiResult<Void>) -> Void)

protocol PersonalInformationRepositoryProtocol {
    func requestPersonalInfo(completion: @escaping RequestPersonalInformationCompletion)
    func sendPersonalInfo(identificationNumber: String?, // personal or id or passport number
                          age: Int?,
                          gender: String?,
                          preexistingConditions: String?,
                          completion: @escaping SendPersonalInfoCompletion)
}

final class PersonalInformationRepository: PersonalInformationRepositoryProtocol {
    // !!! Fields are not required
    func sendPersonalInfo(identificationNumber: String?,
                          age: Int?,
                          gender: String?,
                          preexistingConditions: String?,
                          completion: @escaping SendPersonalInfoCompletion) {
        let normalizedPersonalIdentificationNumber = (identificationNumber?.count == 0) ? nil : identificationNumber
        let request = SendPersonalInformationApiRequest(identificationNumber: normalizedPersonalIdentificationNumber,
                                                        age: age,
                                                        gender: gender,
                                                        preExistingConditions: preexistingConditions)

        request.execute { (data, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
                case .succes:
                    completion(.success(Void()))
                case .failure(let reason):
                    switch reason {
                        case .invalidEgnOrIdNumber:
                            completion(.failure(.invalidEgnOrIdNumber))
                        case .invalidToken:
                            completion(.failure(.invalidToken))
                        case .tooManyRequests:
                            let reapeatAfter = TooManyRequestestHandler().handle(data: data)
                            completion(.failure(.tooManyRequests(reapeatAfter: reapeatAfter)))
                        default:
                            // No special handling
                            completion(.failure(.server))
                }
            }
        }
    }

    func requestPersonalInfo(completion: @escaping RequestPersonalInformationCompletion) {
        GetPersonalInfoRequest().executeParsed(of: PersonalInformation.self) { (personalInformation, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
                case .succes:
                    completion(.success(personalInformation))
                case .failure(let reason):
                    switch reason {
                        case .invalidToken:
                            completion(.failure(.invalidToken))
                        default:
                            completion(.failure(.server))
                }
            }
        }
    }
}
