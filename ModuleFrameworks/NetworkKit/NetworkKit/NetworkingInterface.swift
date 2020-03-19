//
//  NetworkingInterface.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 23.05.18.
//  Copyright © 2018 Valentin Kalchev. All rights reserved.
//

import Foundation

public protocol NetworkingInterface {
    
    /// delegate to handle reachability
    var delegate: ReachabilityProtocol? { get set }
    
    /// Option to pass server trust policies.
    ///
    /// - Parameter serverTrustPolicies: key value pairs where key is the domain as string
    func configureWith(serverTrustPolicies: APITrustPolicies)
    
    /// Sends the passed api request and exposes a callback with the results.
    ///
    /// - Parameters:
    ///   - request: Request object to be executed.
    ///   - completion: callback with request's response, data and error.
    func send(request: APIRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    
    /// Returns whether network is reachable.
    ///
    /// - Returns: true if internet conneciton is available.
    func isConnectedToInternet() -> Bool
    
    /// Starts observing for reachability changes.
    func startNetworkReachabilityObserver()
}
