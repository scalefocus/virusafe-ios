//
//  String+IsNumber.swift
//  ViruSafe
//
//  Created by Ivan Georgiev on 21.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

extension String {
    var isPhoneNumber: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "*"]
        return Set(self).isSubset(of: nums)
    }
    
    var isDigitsOnly: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
