//
//  APIConfig.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 7.08.18.
//

import Foundation

/// Notification fired when the API environment has been changed.
/// To be used by any classes that might need an update in case of the event.
public extension NSNotification.Name {
    static let EnvironmentDidChange = Notification.Name("EnvironmentDidChange")
}

/// Set the default environment here(normally it should be production).
/// This will be used in case the UserDefaults key hasn't been used and set yet.
struct APIConfigConstants {
    static let userDefaultsEnvironmentKey = "upnetix.project.userdefaults.env"
    static let defaultEnvironment: Environment = .dev
}

final class APIConfig {
    
    var environment: Environment {
        didSet {
            let userDefaults = UserDefaults.standard
            let currentUserDefaultsEnvironment = userDefaults.string(forKey: APIConfigConstants.userDefaultsEnvironmentKey)
   
            // Do nothing if the value in UserDefaults is the same
            if let currentEnv = currentUserDefaultsEnvironment,
                currentEnv == environment.rawValue {
                return
            } else { // Set the new value in defaults and post notification
                userDefaults.set(environment.rawValue, forKey: APIConfigConstants.userDefaultsEnvironmentKey)
                NotificationCenter.default.post(name: .EnvironmentDidChange, object: nil)
            }
        }
    }
    
    var authToken: String?
    
    init() {
        let userDefaults = UserDefaults.standard
        if let defaultsEnvironment = userDefaults.string(forKey: APIConfigConstants.userDefaultsEnvironmentKey),
            let environment = Environment(rawValue: defaultsEnvironment) {
            self.environment = environment
        } else {
            self.environment = APIConfigConstants.defaultEnvironment
        }
    }
}
