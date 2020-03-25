//
//  AnswersApiRequest.swift
//  Alamofire
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//

import Foundation

public class AnswersApiRequest: BaseAPIRequest {
    private var phoneNumber: String = ""

    public convenience init(with questionnaire: Questionnaire, phoneNumber: String) {
        self.init(bodyJSONObject: questionnaire.asDictionary())
        self.phoneNumber = phoneNumber
    }
    
    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/questionnaire"
    }

    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var headers: [String: String] {
        var defaultHeaders = super.headers
        defaultHeaders["Accept"] = "*/*"
        defaultHeaders["PhoneNumber"] = phoneNumber
        return defaultHeaders
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}

public struct Questionnaire: Codable {
    public let answers: [Answer]
    public let location: UserLocation
    public let timestamp: Int

    public init(answers: [Answer], location: UserLocation, timestamp: Int) {
        self.answers = answers
        self.location = location
        self.timestamp = timestamp
    }

    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return [:]
        }
        guard let dictionary = json as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}

public struct Answer: Codable {
    public let answer: String
    public let questionId: Int

    public init(answer: String, questionId: Int) {
        self.answer = answer
        self.questionId = questionId
    }
}

public struct UserLocation: Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

