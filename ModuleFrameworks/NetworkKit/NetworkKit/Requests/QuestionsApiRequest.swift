//
//  QuestionsApiRequest.swift
//  Alamofire
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//

import Foundation

public class QuestionsApiRequest: BaseAPIRequest {
    public override var httpMethod: HTTPMethod {
        return .get
    }

    public override var path: String {
        return "/questionnaire"
    }

    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var baseUrlPort: Int? {
        return APIManager.shared.baseURLs.port
    }

    public override var headers: [String: String] {
        var defaultHeaders = super.headers
        defaultHeaders["Accept"] = "application/json"
        return defaultHeaders
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}

public struct Question: Codable {
    public let identifier: Int
    public let title: String
    public let type: String // TODO: Make it enum

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "questionTitle"
        case type = "questionType"
    }
}
