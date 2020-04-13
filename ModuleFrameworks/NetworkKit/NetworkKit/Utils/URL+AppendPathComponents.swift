//
//  URL+AppendPathComponents.swift
//  NetworkKit
//
//  Created by Milen Valchev on 14.06.19.
//

import Foundation

public extension URL {
    
    /// Extension defining functionality for adding multiple path components to URL.
    ///
    /// - Parameter pathComponents: array of path components
    mutating func appendPathComponents(_ pathComponents: [String]) {
        pathComponents.forEach { appendPathComponent($0) }
    }
    
}
