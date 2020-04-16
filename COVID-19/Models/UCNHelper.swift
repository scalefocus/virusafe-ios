//
//  UCNHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 1.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

enum UCNType {
    case bulgarian
    case macedonian
}

protocol UCNHelper {
    var maximumPersonalNumberLength: Int { get }
    var ucnType: UCNType { get }

    func parse(ucn: String) -> UCNData?
    func isValid(ucn: String) -> Bool
}

// Bulgarian

final class BGUCNHelper: UCNHelper {

    // MARK: UCNHelperType

    let maximumPersonalNumberLength = 10

    let ucnType: UCNType = .bulgarian

    func parse(ucn: String) -> UCNData? {
        guard isValid(ucn: ucn) else {
            // can not parse invalid ucn
            return nil
        }

        // we already know that date components are valid, so just in case
        guard let year = year(ucn: ucn), let month = month(ucn: ucn), let day = day(ucn: ucn) else {
            return nil
        }

        guard let sex = sex(ucn: ucn) else {
            return nil
        }

        let normalized = normalize(day: day, month: month, year: year)
        return UCNData(day: normalized.day,
                       month: normalized.month,
                       year: normalized.year,
                       sex: sex)
    }

    func isValid(ucn: String) -> Bool {
        guard ucn.count == maximumPersonalNumberLength else {
            // Invalid length
            return false
        }

        guard let year = year(ucn: ucn), let month = month(ucn: ucn), let day = day(ucn: ucn) else {
            // Can not read date components
            return false
        }

        let normalized = normalize(day: day, month: month, year: year)

        guard validate(day: normalized.day, month: normalized.month, year: normalized.year) else {
            // bad date
            return false
        }

        guard validateChecksum(ucn: ucn) else {
            // bad checksum
            return false
        }

        return true
    }

    // MARK: Helpers

    private let weights: [Int]  = [2, 4, 8, 5, 10, 9, 7, 3, 6]

    private func year(ucn: String) -> Int? {
        return Int(ucn.substring(0..<2))
    }

    private func month(ucn: String) -> Int? {
        return Int(ucn.substring(2..<4))
    }

    private func day(ucn: String) -> Int? {
        return Int(ucn.substring(4..<6))
    }

    private func sex(ucn: String) -> Gender? {
        let index = ucn.index(ucn.startIndex, offsetBy: 8)
        guard let value = Int(String(ucn[index])) else {
            return nil
        }
        let sex = value % 2
        return sex != 0 ? .female : .male
    }

        //swiftlint:disable:next large_tuple
    private func normalize(day: Int, month: Int, year: Int) -> (day: Int, month: Int, year: Int) {
        if month > 40 {
            return (day: day, month: month - 40, year: year + 2000)
        } else if month > 20 {
            return (day: day, month: month - 20, year: year + 1800)
        } else {
            return (day: day, month: month, year: year + 1900)
        }
    }

    private let calendar = Calendar.current

    private func validate(day: Int, month: Int, year: Int) -> Bool {
        let dateComponents = DateComponents(calendar: calendar,
                                            year: year,
                                            month: month,
                                            day: day)
        return dateComponents.isValidDate
    }

    private func validateChecksum(ucn: String) -> Bool {
        guard let lastChart = ucn.last else { return false }
        let checksum = Int(String(lastChart))
        var sum: Int = 0
        for offset in 0..<9 {
            let index = ucn.index(ucn.startIndex, offsetBy: offset)
            sum += ((Int(String(ucn[index])) ?? 0) * weights[offset])
        }
        var calculatedChecksum = sum % 11
        if calculatedChecksum == 10 {
            calculatedChecksum = 0
        }

        return checksum == calculatedChecksum
    }
}

// Macedonian

final class MKUCNHelper: UCNHelper {

    // MARK: UCNHelperType

    let maximumPersonalNumberLength = 13

    let ucnType: UCNType = .macedonian

    func parse(ucn: String) -> UCNData? {
        guard isValid(ucn: ucn) else {
            // can not parse invalid ucn
            return nil
        }

        // we already know that date components are valid, so just in case
        guard let year = year(ucn: ucn), let month = month(ucn: ucn), let day = day(ucn: ucn) else {
            return nil
        }

        guard let sex = sex(ucn: ucn) else {
            return nil
        }

        let normalized = normalize(day: day, month: month, year: year)
        return UCNData(day: normalized.day,
                       month: normalized.month,
                       year: normalized.year,
                       sex: sex)
    }

    func isValid(ucn: String) -> Bool {
        guard ucn.count == maximumPersonalNumberLength else {
            // Invalid length
            return false
        }

        guard let year = year(ucn: ucn), let month = month(ucn: ucn), let day = day(ucn: ucn) else {
            // Can not read date components
            return false
        }

        let normalized = normalize(day: day, month: month, year: year)

        guard validate(day: normalized.day, month: normalized.month, year: normalized.year) else {
            // bad date
            return false
        }

        guard validateChecksum(ucn: ucn) else {
            // bad checksum
            return false
        }

        return true
    }

    // MARK: Helpers

    private let weights: [Int]  = [7, 6, 5, 4, 3, 2]

    private func year(ucn: String) -> Int? {
        guard let yyy = Int(ucn.substring(4..<7)) else {
            return nil
        }

        return 1000 + yyy
    }

    private func month(ucn: String) -> Int? {
        return Int(ucn.substring(2..<4))
    }

    private func day(ucn: String) -> Int? {
        return Int(ucn.substring(0..<2))
    }

    private func sex(ucn: String) -> Gender? {
        guard let sex = Int(ucn.substring(9..<12)) else {
            return nil
        }
        return sex > 499 ? .female : .male
    }

    //swiftlint:disable:next large_tuple
    private func normalize(day: Int, month: Int, year: Int) -> (day: Int, month: Int, year: Int) {
        // Handle years after 2000.
        if year <= 1800 {
            return (day: day, month: month, year: year + 1000)
        }

        return (day: day, month: month, year: year)
    }

    private let calendar = Calendar.current

    private func validate(day: Int, month: Int, year: Int) -> Bool {
        let dateComponents = DateComponents(calendar: calendar,
                                            year: year,
                                            month: month,
                                            day: day)
        return dateComponents.isValidDate
    }

    private func validateChecksum(ucn: String) -> Bool {
        let checksum = ucn.wholeNumberForCharacter(offsetBy: 12)
        var sum: Int = 0

        let weightsCount = weights.count

        for offset in 0..<weightsCount {
            sum += (
                weights[offset]
                    * (ucn.wholeNumberForCharacter(offsetBy: offset) + ucn.wholeNumberForCharacter(offsetBy: weightsCount + offset))
            )
        }

        var calculatedChecksum = 11 - sum % 11
        if calculatedChecksum > 9 {
            calculatedChecksum = 0
        }

        return checksum == calculatedChecksum
    }
}

// MARK: Substring Helper

extension String {
    func substring(_ range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }

    func wholeNumberForCharacter(offsetBy offset: Int) -> Int {
        let index = self.index(self.startIndex, offsetBy: offset)
        return Int(String(self[index])) ?? 0
    }
}
