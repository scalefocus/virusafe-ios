//
//  TokenApiRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//

import Foundation

public class TokenApiRequest: BaseAPIRequest {
    public convenience init(phoneNumber: String, pin: String) {
        let jsonDict: [String: Any] = [
            "phoneNumber": phoneNumber,
            "pin": pin
        ]
        self.init(bodyJSONObject: jsonDict, tokenRefreshCount: 0)
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/token"
    }

    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var headers: [String: String] {
        var defaultHeaders = super.headers
        defaultHeaders.removeValue(forKey: "Authorization")
        return defaultHeaders
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}

public struct ApiToken: Codable {
    public let accessToken: String
}

public struct ApiError: Codable {
    public let timestamp: String
    public let message: String
}
