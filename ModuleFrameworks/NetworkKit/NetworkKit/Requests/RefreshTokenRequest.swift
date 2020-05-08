//
//  RefreshTokenRequest.swift
//  NetworkKit
//
//  Created by Nadezhda on 16.04.20.
//

public class RefreshTokenRequest: BaseAPIRequest {
    public convenience init(refreshToken: String) {
        let jsonDict: [String: Any] = ["refreshToken": refreshToken]
        self.init(bodyJSONObject: jsonDict, tokenRefreshCount: 0)
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/token/refresh"
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
