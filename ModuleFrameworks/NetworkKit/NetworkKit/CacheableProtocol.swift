//
//  CacheableInterface.swift
//  NetworkKit
//
//  Created by Plamen Penchev on 4.09.18.
//

import Foundation

/// Defines the methods the cacher should implement
public protocol CacheableProtocol {
    
    /// Implement this method to handle data caching based on the request passed.
    ///
    /// - Parameters:
    ///   - data: Data to be cached (in bytes).
    ///   - request: The request that retrieves the data.
    func cache(data: Data, for request: APIRequest)
    
    /// Implement this method to load cached data for the passed request.
    ///
    /// - Parameter request: The API request that retrieves the data
    /// - Returns: cached data in bytes
    func loadCache(for request: APIRequest) -> Data?
}
