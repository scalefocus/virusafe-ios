//
//  ProximityApiRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 2.04.20.
//

import Foundation

public class ProximityApiRequest: BaseAPIRequest {
    public convenience init(location: UserLocation, nearbyDevices: [Proximitiy], timestamp: String) {
        let proximities = nearbyDevices.map { $0.asDictionary() }
        let jsonDict: [String: Any] = [
            "location": location.asDictionary(),
            "proximities": proximities,
            "timestamp": timestamp
        ]
        self.init(bodyJSONObject: jsonDict)
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/location/proximity"
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

    public override var shouldWorkInBackground: Bool {
        return true
    }
}

public struct Proximitiy: Codable {
    public var distance: String
    public var uuid: String

    public init(distance: String, uuid: String) {
        self.distance = distance
        self.uuid = uuid
    }
}
