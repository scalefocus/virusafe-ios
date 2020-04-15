//
//  UCNData.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 10.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

struct UCNData {
    var day: Int
    var month: Int
    var year: Int
    var sex: Gender

    var birthdate: Date? {
        let dateComponents = DateComponents(calendar: calendar,
                                            year: year,
                                            month: month,
                                            day: day)
        return dateComponents.date
    }

    // MARK: Helpers

    private let calendar = Calendar.current
}
