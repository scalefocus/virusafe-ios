//
//  StatusCode+Utils.swift
//  Alamofire
//
//  Created by Valentin Kalchev on 6.06.18.
//

import Foundation

// todo: Should refactor in custom enum to not spoil Int
public extension Int {
    /// Informational - Request received, continuing process.
    public var isInformational: Bool {
        return isIn(range: 100...199)
    }
    /// Success - The action was successfully received, understood, and accepted.
    public var isSuccess: Bool {
        return isIn(range: 200...299)
    }
    /// Redirection - Further action must be taken in order to complete the request.
    public var isRedirection: Bool {
        return isIn(range: 300...399)
    }
    /// Client Error - The request contains bad syntax or cannot be fulfilled.
    public var isClientError: Bool {
        return isIn(range: 400...499)
    }
    /// Server Error - The server failed to fulfill an apparently valid request.
    public var isServerError: Bool {
        return isIn(range: 500...599)
    }
    /// Invalid status code - not a status code
    public var isInvalid: Bool {
        return !isIn(range: 100...599)
    }
    
    /// - returns: `true` if the status code is in the provided range, false otherwise.
    private func isIn(range: ClosedRange<Int>) -> Bool {
        return range.contains(self)
    }
}
