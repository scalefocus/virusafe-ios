//
//  PinApiRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//

import Foundation

public class PinApiRequest: BaseAPIRequest {
    public convenience init(phoneNumber: String) {
        self.init(bodyJSONObject: ["phoneNumber": phoneNumber])
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/pin"
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
