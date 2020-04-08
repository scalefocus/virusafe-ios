//
//  Servers.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 31.05.18.
//  Copyright © 2018 Valentin Kalchev. All rights reserved.
//

import Foundation

public enum Environment: String {
    case dev, stage, live
    
    public var value: EnvironmentInterface {
        switch self {
        case .dev: return DevEnvironment()
        case .stage: return StageEnvironment()
        case .live: return LiveEnvironment()
        }
    }
    
    public static let allValues: [Environment] = [dev, stage, live]
}

public protocol EnvironmentInterface {
    var name: String {get set}
    var baseURLs: BaseURLs {get set}
    // Make sure certificates are added in the bundle if ssl pinning policies are added
    var serverTrustPolicies: APITrustPolicies { get set }
}

public typealias BaseURL = String
public protocol BaseURLs {
    var base: BaseURL { get set }
    var port: Int? { get set }
}

public typealias APITrustPolicies = [String: NetworkServerTrustPolicy]
public enum NetworkServerTrustPolicy {
    case none
    case pinCertificates
    case pinPublicKeys
}

/*************************************/
// - MARK: Dev Environment
/*************************************/

struct DevEnvironment: EnvironmentInterface {
    var name = "Development"
    var baseURLs: BaseURLs = DevBaseURLs()
    var serverTrustPolicies: APITrustPolicies = [:]
    
    /*************************************/
    //  Example public key pinning:
    //
    //    var serverTrustPolicies: APITrustPolicies = [
    //        "tasks.upnetix.tech": .pinPublicKeys
    //    ]
    //
    /*************************************/
}

struct DevBaseURLs: BaseURLs {
    var base: BaseURL = "https://virusafe.scalefocus.dev"
    var port: Int? = nil
}

/*************************************/
// - MARK: Stage Environment
/*************************************/

struct StageEnvironment: EnvironmentInterface {
    var name = "Stage"
    var baseURLs: BaseURLs = StageBaseURLs()
    var serverTrustPolicies: APITrustPolicies = [:]
}

struct StageBaseURLs: BaseURLs {
    var base: BaseURL = "https://virusafe.io"
    var port: Int? = nil
}

/*************************************/
// - MARK: Live Environment
/*************************************/

struct LiveEnvironment: EnvironmentInterface {
    var name = "Live"
    var baseURLs: BaseURLs = LiveBaseURLs()
    var serverTrustPolicies: APITrustPolicies = [:]
}

struct LiveBaseURLs: BaseURLs {
    var base: BaseURL = "https://virusafe.io"
    var port: Int? = nil
}
