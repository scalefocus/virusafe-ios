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
    var questionTitle: String
    var isActive: Bool?
}

