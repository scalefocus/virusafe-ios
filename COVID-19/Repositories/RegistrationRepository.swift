//
//  RegistrationRepository.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

class RegistrationRepository {

    private (set) var authorisedMobileNumber: String?
    
    func authoriseMobileNumber(mobileNumber: String, completion: (Bool) -> Void) {
        // TODO: Implement request here
        // TODO: Store mobile number only on success
        authorisedMobileNumber = mobileNumber
        completion(true)
    }
    
    func authoriseVerificationCode(verivicationCode: String, completion: (Bool) -> Void) {
        // TODO: Implement request here
        completion(true)
    }
    
}
