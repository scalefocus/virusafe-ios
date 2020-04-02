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
    var phoneNumber: String?
    var age: Int?
    var gender: Gender?
    var preExistingConditions: String?
}
