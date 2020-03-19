//
//  ParserInterface.swift
//  NetworkKit
//
//  Created by Plamen Penchev on 4.09.18.
//

import Foundation

/// Classes conforming to this protocol can be used as parser within APIRequest
public protocol ParserInterface {
    /// Implement this method to parse bytes of data to any Codable
    ///
    /// - Parameters:
    ///   - data: bytes of data
    ///   - ofType: any Codable type
    /// - Returns: parsed data to desired type
    func parse<T: Codable>(data: Data?, ofType: T.Type) -> T?
}
