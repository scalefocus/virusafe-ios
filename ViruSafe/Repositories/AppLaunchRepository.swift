//
//  AppLaunchRepository.swift
//  ViruSafe
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class AppLaunchRepository {

    private var userDefaults = UserDefaults.standard

    var isAppLaunchedBefore: Bool {
        get {
            return userDefaults.bool(forKey: "launched_before")
        }
        set {
            userDefaults.set(newValue, forKey: "launched_before")
            userDefaults.synchronize()
        }
    }
}
