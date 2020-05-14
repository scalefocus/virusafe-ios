//
//  UUID+data.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

public extension UUID {
    var data: Data {
        return withUnsafeBytes(of: self.uuid, { Data($0) })
    }
}
