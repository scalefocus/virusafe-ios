//
//  HealthStatus.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

struct HealthStatus: Codable {
    var questions: [HealthStatusQuestion]?
}

struct HealthStatusQuestion: Codable {
    let questionId: Int
    var questionTitle: String
    // TODO: Add type
    // supports only boolean
    var isActive: Bool? // if value is set - it is answered
}

