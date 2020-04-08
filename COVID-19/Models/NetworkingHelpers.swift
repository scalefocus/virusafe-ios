//
//  NetworkingHelpers.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

struct RemoteConfigEnvironment: EnvironmentInterface {
    var name = "FirebaseConfig"
    var baseURLs: BaseURLs
    var serverTrustPolicies: APITrustPolicies = [:]
}

struct RemoteStageBaseURLs: BaseURLs {
    var base: BaseURL
    var port: Int?
}
