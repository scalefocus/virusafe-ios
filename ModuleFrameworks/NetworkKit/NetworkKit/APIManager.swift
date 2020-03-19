//
//  APIManager.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 31.05.18.
//  Copyright © 2018 Valentin Kalchev. All rights reserved.
//

import Foundation

public protocol AuthenticationProtocol {
    func getApiToken(completion: ((String?) -> Void)?)
}

public protocol ApiManagerProtocol {
    var authToken: String? { get set }
    var baseURLs: BaseURLs { get }
    var environment: Environment { get set }
    
    func sendRequest(request: APIRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    func configure(withCacher: CacheableProtocol?, reachabilityDelegate: ReachabilityProtocol?, authenticator: AuthenticationProtocol?)
    
    func startReachabilityObserving()
    func isConnectedToInternet() -> Bool
}

public final class APIManager: ApiManagerProtocol {
    
    public static let shared = APIManager()
    
    /// The API configuration, such as authentication token, environment, base urls, etc.
    private var config = APIConfig()
    private var cacher: CacheableProtocol?
    private var networker: NetworkingInterface = Networker()
    private var authenticator: AuthenticationProtocol?
    
    /// The currently used authentication token. Used for convenience and public accessibility, must always point to the APIConfig instance.
    public final var authToken: String? {
        set(newValue) {
            config.authToken = newValue
        }
        get {
            return config.authToken
        }
    }
    
    /// The current selected environments' base URLs. This should always return the values from the APIConfig instance.
    /// The APIConfig base URLs must NOT be publicly mutable, they're only set in
    /// EnvironmentsAndBaseURLs and held by the APIConfig instance.
    /// Used for convenience.
    public final var baseURLs: BaseURLs {
        return config.environment.value.baseURLs
    }
    
    /// The current selected environment in the APIConfig instance. Just for convenience and accessibility, should always point to the APIConfig instance.
    public final var environment: Environment {
        set(newValue) {
            config.environment = newValue
        }
        get {
            return config.environment
        }
    }
    
    /// Handles caching request execution.
    ///
    /// - Parameters:
    ///   - request: The APIRequest to be executed.
    ///   - completion: callback Data, Response, Error
    public final func sendRequest(request: APIRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        networker.send(request: request) { [weak self] (data, urlResponse, error) in
            guard let strongSelf = self else { return }
            // Check if the authorization for the request fails and try to authenticate and re-send
            // the request again
            if let response = urlResponse, response.statusCode == 401, (request.tokenRefreshCount ?? 0) > 0 {
                strongSelf.authenticator?.getApiToken { (token) in
                    strongSelf.authToken = token
                    var updatedRequest = request
                    updatedRequest.tokenRefreshCount = (updatedRequest.tokenRefreshCount ?? 0) - 1
                    strongSelf.sendRequest(request: updatedRequest, completion: completion)
                    print("DEBUG: UNAUTHORIZED, RETRY AUTHORIZATION.")
                    return
                }
                // HANDLE Cache logic
            } else if request.shouldCache {
                if !strongSelf.networker.isConnectedToInternet() {
                    let cachedData = strongSelf.cacher?.loadCache(for: request)
                    completion(cachedData, urlResponse, ErrorsToThrow.noInternet)
                } else if let data = data {
                    strongSelf.cacher?.cache(data: data, for: request)
                    completion(data, urlResponse, error)
                } else {
                    completion(data, urlResponse, error)
                }
            } else {
                // Handle normal execution of request which should not be cached.
                // Custom error is passed if there's
                if !strongSelf.networker.isConnectedToInternet() {
                    completion(data, urlResponse, ErrorsToThrow.noInternet)
                } else {
                    completion(data, urlResponse, error)
                }
            }
        }
    }
    
    /// Configure the APIManager cacher.
    ///
    /// - Parameter cacher: Class conforming to CacheableInterface.
    public final func configure(withCacher: CacheableProtocol?, reachabilityDelegate: ReachabilityProtocol?, authenticator: AuthenticationProtocol?) {
        self.authenticator = authenticator
        cacher = withCacher
        networker.delegate = reachabilityDelegate
        networker.configureWith(serverTrustPolicies: environment.value.serverTrustPolicies)
    }
    
    public final func startReachabilityObserving() {
        networker.startNetworkReachabilityObserver()
    }
    
    public final func isConnectedToInternet() -> Bool {
        return networker.isConnectedToInternet()
    }
}

// Error to pass when no connection is available.
public enum ErrorsToThrow: Error {
    case noInternet
}
