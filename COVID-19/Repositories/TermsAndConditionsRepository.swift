//
//  TermsAndConditionsRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class TermsAndConditionsRepository: NSObject {

    private var userDefaults = UserDefaults.standard

    @objc dynamic var isAgree: Bool {
        get {
            return userDefaults.bool(forKey: "user_accepted_app_terms")
        }
        set {
            userDefaults.set(newValue, forKey: "user_accepted_app_terms")
        }
    }

    @objc dynamic var isAgreeDataProtection: Bool {
        get {
            return userDefaults.bool(forKey: "user_accepted_data_protection")
        }
        set {
            userDefaults.set(newValue, forKey: "user_accepted_data_protection")
        }
    }

}
