//
//  LanguageHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 9.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class LanguageHelper {

    // MARK: Singleton

    static let shared = LanguageHelper()
    private init() { }

    // MARK: Helpers

    private let defaults = UserDefaults.standard
    private var defaultLocale: String {
        #if MACEDONIA
        return "mk"
        #else
        return "bg"
        #endif
    }

    // MARK: Public

    var savedLocale: String {
        get {

            return defaults.string(forKey: .savedLocaleUserDefaultsKey) ?? defaultLocale
        }
        set {
            // ??? Normalize/verify new value
            UserDefaults.standard.setValue(newValue, forKeyPath: .savedLocaleUserDefaultsKey)
        }
    }

    var languageCode: String {
        let locale = Locale(identifier: savedLocale)
        let languageCode = locale.languageCode ?? defaultLocale
        return languageCode
    }

}

private extension String {
    static let savedLocaleUserDefaultsKey = "userLocale"
}
