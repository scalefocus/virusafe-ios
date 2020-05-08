//
//  UIDevice+Helpers.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 21.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

extension UIDevice {
    var modelIdentifier: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return "Simulator_\(simulatorModelIdentifier)"
        }

        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let deviceModelIdentifier = String(bytes: data, encoding: .ascii) else {
            fatalError("Can't find Device Model Identifier")
        }
        return deviceModelIdentifier.trimmingCharacters(in: .controlCharacters)
    }

    var version: String {
        return "\(systemName)/\(systemVersion)"
    }

    var darwinVersion: String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN))
        guard let darwin = String(bytes: data, encoding: .ascii) else {
            fatalError("Can't find Darwin")
        }
        return darwin.trimmingCharacters(in: .controlCharacters)
    }
}
