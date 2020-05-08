//
//  BaseAPIRequest.swift
//  NetworkKit
//
//  Created by Plamen Penchev on 26.09.18.
//

import Foundation

public class BaseAPIRequest: APIRequest {

    public var httpMethod: HTTPMethod {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }

    public var baseUrl: BaseURL {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }

    public var path: String {
        return ""
    }

    public var authorizationRequirement: AuthorizationRequirement {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }

    public var headers: [String: String] {
        var dict: [String: String] = ["Content-Type": "application/json"]

        // NOTE: Should be in all API Calls
        if let clientId = APIManager.shared.clientId {
            dict["ClientId"] = clientId
        }

        if let token = APIManager.shared.authToken {
            dict["Authorization"] = "Bearer \(token)"
        }
        return dict
    }

    public var userAgent: String?

    public var shouldHandleCookies: Bool? {
        return nil
    }

    public var shouldCache: Bool {
        return false
    }

    public var timeout: TimeInterval {
        return 30
    }

    public var shouldWorkInBackground: Bool {
        return false
    }

    public var tokenRefreshCount: Int?

    public var pathParameters: [String]?
    public var queryParameters: [String: String]?
    public var bodyJSONObject: Any?
    public var bodyFormURLEncoded: [String: String]?
    public var parser: ParserInterface?

    public var customCachingIdentifierParams: [String: String]?
    public var customCachingIdentifier: String? {
        return endpoint?.absoluteString
    }

    required public init(pathParameters: [String]? = nil,
                         queryParameters: [String: String]? = nil,
                         bodyJSONObject: Any? = nil,
                         bodyFormURLEncoded: [String: String]? = nil,
                         parser: ParserInterface? = nil,
                         tokenRefreshCount: Int? = 1,
                         customCachingIdentifierParams: [String: String]? = nil) {
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.bodyJSONObject = bodyJSONObject
        self.bodyFormURLEncoded = bodyFormURLEncoded
        self.parser = parser
        self.tokenRefreshCount = tokenRefreshCount
        self.customCachingIdentifierParams = customCachingIdentifierParams
    }

}
