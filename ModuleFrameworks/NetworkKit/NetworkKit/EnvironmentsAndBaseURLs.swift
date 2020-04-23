//
//  Servers.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 31.05.18.
//  Copyright © 2018 Valentin Kalchev. All rights reserved.
//

import Foundation

final class Environment {

    // MARK: - Singleton

    static let shared = Environment()
    private init() { }

    private var configurationDictionary: [String: Any] {
        // NOTE: We already have config file for firebase defaults
        guard let path = Bundle.main.path(forResource: "RemoteConfigDefaults", ofType: "plist") else {
            fatalError("Environment config plist file not found")
        }

        guard let configuration = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            // Nothing to return
            return [:]
        }

        return configuration
    }

    /// - Parameters: key - from PlistKey Type
    /// - Returns: String
    ///  The real string of the property with the same name like into .plist file
    func configuration(_ key: PlistKey) -> String {
        guard let value = configurationDictionary[key.value] as? String else {
            fatalError("Environment invalid config key \(key.value)")
        }

        return value
    }
}

//

enum PlistKey {

    /// API Base URL
    case serverUrl

    //    /// API Trust Policies
    //    case trustPolicies

    var value: String {
        switch self {
        case .serverUrl:
            return "ios_end_point"
            //            case .trustPolicies:
            //                return "ios_trust_policies"
        }
    }

}

public protocol EnvironmentInterface {
    var name: String {get set}
    var baseURLs: BaseURLs {get set}
    // NOTE: Make sure certificates are added in the bundle if ssl pinning policies are added
    var serverTrustPolicies: APITrustPolicies { get set }
}

public typealias BaseURL = String
public struct BaseURLs {
    public var base: BaseURL

    public init(base: BaseURL) {
        self.base = base
    }
}

public typealias APITrustPolicies = [String: NetworkServerTrustPolicy]
public enum NetworkServerTrustPolicy: String {
    case none
    case pinCertificates
    case pinPublicKeys
}

/*************************************/
//  Example public key pinning:
//
//    var serverTrustPolicies: APITrustPolicies = [
//        "tasks.upnetix.tech": .pinPublicKeys
//    ]
//
/*************************************/
