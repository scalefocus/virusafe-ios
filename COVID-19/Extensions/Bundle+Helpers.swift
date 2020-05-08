//
//  Bundle+Helpers.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 21.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String {
        guard let versionNumber = infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError("Can't find CFBundleShortVersionString")
        }
        return versionNumber
    }

    var buildVersionNumber: String {
        guard let versionNumber = infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Can't find CFBundleVersion")
        }
        return versionNumber
    }

    var applicationDisplayName: String {
        if let applicationName = infoDictionary?["CFBundleDisplayName"] as? String {
            return applicationName
        } else {
            return self.applicationName
        }
    }

    var applicationName: String {
        guard let applicationName = infoDictionary?["CFBundleName"] as? String else {
            fatalError("Can't find CFBundleName")
        }
        return applicationName
    }
}
