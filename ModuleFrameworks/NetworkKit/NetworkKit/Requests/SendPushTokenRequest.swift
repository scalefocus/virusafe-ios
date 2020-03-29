//
//  SendPushTokenRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 29.03.20.
//

import Foundation

public class SendPushTokenRequest: BaseAPIRequest {
    public convenience init(pushToken: String) {
        let jsonDict: [String: Any] = ["pushToken": pushToken]
        self.init(bodyJSONObject: jsonDict)
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/pushtoken"
    }

    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var baseUrlPort: Int? {
        return APIManager.shared.baseURLs.port
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}
