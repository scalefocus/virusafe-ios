//
//  EGNHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 1.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

struct EGNData {
    var day: Int
    var month: Int
    var year: Int
    var sex: Gender

    var birthdate: Date? {
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar,
                                            year: year,
                                            month: month,
                                            day: day)
        return dateComponents.date
    }
}

final class UCNHelper {

    private let weights: [Int]  = [2, 4, 8, 5, 10, 9, 7, 3, 6]
    private let length = 10

    func parse(egn: String) -> EGNData? {
        guard isValid(egn: egn) else {
            // can not parse invalid egn
            return nil
        }

        // we already know that date components are valid, so just in case
        guard let year = year(egn: egn), let month = month(egn: egn), let day = day(egn: egn) else {
            return nil
        }

        guard let sex = sex(egn: egn) else {
            return nil
        }

        let normalized = normalize(day: day, month: month, year: year)
        return EGNData(day: normalized.day, month: normalized.month, year: normalized.year, sex: sex)
    }

    func isValid(egn: String) -> Bool {
        guard egn.count == length else {
            // Invalid length
            return false
        }
        guard let year = year(egn: egn), let month = month(egn: egn), let day = day(egn: egn) else {
            // Can not read date components
            return false
        }

        let normalized = normalize(day: day, month: month, year: year)
        guard validate(day: normalized.day, month: normalized.month, year: normalized.year) else {
            // bad date
            return false
        }

        guard validateChecksum(egn: egn) else {
            // bad checksum
            return false
        }

        return true
    }

    private func year(egn: String) -> Int? {
        return Int(egn.substring(0..<2))
    }

    private func month(egn: String) -> Int? {
        return Int(egn.substring(2..<4))
    }

    private func day(egn: String) -> Int? {
        return Int(egn.substring(4..<6))
    }

    private func sex(egn: String) -> Gender? {
        let index = egn.index(egn.startIndex, offsetBy: 8)
        guard let value = Int(String(egn[index])) else {
            return nil
        }
        let sex = value % 2
        return sex != 0 ? .female : .male
    }

    private func normalize(day: Int, month: Int, year: Int) -> (day: Int, month: Int, year: Int) {
        if month > 40 {
            return (day: day, month: month - 40, year: year + 2000)
        } else if month > 20 {
            return (day: day, month: month - 20, year: year + 1800)
        } else {
            return (day: day, month: month, year: year + 1900)
        }
    }

    private func validate(day: Int, month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar,
                                            year: year,
                                            month: month,
                                            day: day)
        return dateComponents.isValidDate
    }

    private func validateChecksum(egn: String) -> Bool {
        let checksum = Int(String(egn.last!))
        var sum: Int = 0
        for offset in 0..<9 {
            let index = egn.index(egn.startIndex, offsetBy: offset)
            sum += ((Int(String(egn[index])) ?? 0) * weights[offset])
        }
        var calculatedChecksum = sum % 11
        if calculatedChecksum == 10 {
            calculatedChecksum = 0
        }

        return checksum == calculatedChecksum
    }
}

extension String {
    func substring(_ range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

//

final class PINForeignerHelper {
    private let weights: [Int]  = [21, 19, 17, 13, 11, 9, 7, 3, 1]
    private let length = 10

    func isValid(pin: String) -> Bool {
        guard pin.count == length else {
            // Invalid length
            return false
        }

        guard validateChecksum(pin: pin) else {
            // bad checksum
            return false
        }

        return true
    }

    private func validateChecksum(pin: String) -> Bool {
        let checksum = Int(String(pin.last!))
        var sum: Int = 0
        for offset in 0..<9 {
            let index = pin.index(pin.startIndex, offsetBy: offset)
            sum += ((Int(String(pin[index])) ?? 0) * weights[offset])
        }
        let calculatedChecksum = sum % 10
        return checksum == calculatedChecksum
    }
}

final class IDCardHelper {
    private let length = 10
    
    func isValid(id: String) -> Bool {
        return id.count == length
    }
}
