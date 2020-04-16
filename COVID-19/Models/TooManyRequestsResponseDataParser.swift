//
//  TooManyRequestsResponseDataParser.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 2.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

enum Timeout {
    static let defaultInSeconds: Int = 0
}

struct TooManyRequestsResponse: Codable {
    var timestamp: String?
    var message: String
    var cause: String?
    var errors: [String]?
}

extension TooManyRequestsResponse {
    var reapeatAfter: Int {
        guard let seconds = Int(message) else {
            return Timeout.defaultInSeconds
        }
        return seconds
    }
}

struct TooManyRequestsResponseDataParser {
    func parse(_ data: Data) -> TooManyRequestsResponse? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(TooManyRequestsResponse.self, from: data)
    }
}

extension UIAlertController {
    static func rateLimitExceededAlert(repeatAfterSeconds: Int) -> UIAlertController {
        var message = "too_many_requests_msg".localized().replacingOccurrences(of: "%1$@", with: "") + " "

        let parsed = convertSecondsToHoursMinutesSeconds(repeatAfterSeconds)

        if parsed.hours > 0 {
            message += ("\(parsed.hours) " + "hours_label".localized())
        }

        if parsed.minutes > 0 {
            if parsed.hours > 0 {
                message += " "
            }
            message += ("\(parsed.minutes) " + "minutes_label".localized())
        }

        if parsed.hours == 0 && parsed.minutes == 0 {
            message += "little_more_time".localized()
        }

        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok_label".localized(),
                                      style: .default,
                                      handler: nil))
        return alert
    }

    //swiftlint:disable:next large_tuple
    private static func convertSecondsToHoursMinutesSeconds(_ seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
