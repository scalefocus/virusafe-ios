//
//  PersonalInformation.swift
//  COVID-19
//
//  Created by Valentin Kalchev on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

struct PersonalInformation: Codable {
    var identificationNumber: String? // egn/id/pasport number
    var identificationType: IdentificationNumberType?
    var phoneNumber: String? // !!! It is not important in the request, but esential in the response
    var age: Int?
    var gender: Gender?
    var preExistingConditions: String?
}
