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
    var hasSymptoms: Bool?
    var canUpdate: Bool
}

struct HealthStatusQuestion: Codable {
    var questionTitle: String
    var isActive: Bool?
}

