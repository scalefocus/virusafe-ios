//
//  UtilFunctions.swift
//  ViruSafe
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

/// Delay a closure and call it async on the main thread
///
/// - Parameters:
///   - delay: the delay time in seconds
///   - closure: the closure that is called after the delay
public func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue
        .main
        .asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                    execute: closure)
}
