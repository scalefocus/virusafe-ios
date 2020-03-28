//
//  AppLaunchRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class AppLaunchRepository {

    private var userDefaults = UserDefaults.standard

    var isAppLaunchedBefore: Bool {
        get {
            if userDefaults.bool(forKey: "launched_before") {
                return true
            }

            userDefaults.set(true, forKey: "launched_before")
            return false
        }
    }
}
