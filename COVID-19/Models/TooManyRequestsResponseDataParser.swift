//
//  TooManyRequestsResponseDataParser.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 2.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

enum Timeout {
    static let defaultInSeconds: Int = 0
}

struct TooManyRequestsResponse: Codable {
    var timestamp: String
    var message: String
    var cause: String?
    var errors: [String]
}

struct TooManyRequestsResponseDataParser {
    func parse(_ data: Data) -> TooManyRequestsResponse? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(TooManyRequestsResponse.self, from: data)
    }
}

extension TooManyRequestsResponse {
    var reapeatAfter: Int {
        guard let seconds = Int(message) else {
            return Timeout.defaultInSeconds
        }
        return seconds
    }
}

extension UIAlertController {
    static func rateLimitExceededAlert(repeatAfterSeconds: Int) -> UIAlertController {
        var message = "too_many_requests_msg".localized() + " "

        let hours = repeatAfterSeconds / 3600
        if hours > 0 {
            message += ("\(hours) " + "hours_label".localized())
        }

        let minutes = repeatAfterSeconds / 60
        if minutes > 0 {
            message += ("\(minutes) " + "minutes_label".localized())
        }

        if hours == 0 && minutes == 0 {
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
}
