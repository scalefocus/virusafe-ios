//
//  RemoteConfigHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import Firebase

enum RemoteConfigValueKey: String {
    case mandatory = "ios_is_mandatory"
    case latestAppVersion = "ios_latest_app_version"
    case appstoreLink = "ios_appstore_link"
    case endpointURL = "ios_end_point"
    // not used
//    case contentPageURL = "ios_static_content_page_url"
//    case appInfoPageURL = "ios_app_info_page_url"
    case statisticsPageURL = "statistics_url"
    case locationIntervalMinutes = "ios_location_interval_in_mins"
    case statisticsButtonVisible = "is_statistics_btn_visible"
}

final class RemoteConfigHelper {

    private var remoteConfig = RemoteConfig.remoteConfig()

    // MARK: Singleton

    static let shared = RemoteConfigHelper()

    private init() {
        setupDefaults()
        setupRemoteConfigSettings()
    }

    // MARK: Defaults

    private func setupDefaults() {
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    // MARK: Settings

    // Get remote settings every 2 min
    private let minimumFetchInterval: TimeInterval = 120

    var isDeveloperModeEnabled: Bool = false

    private func setupRemoteConfigSettings() {
        let settings = RemoteConfigSettings()
        if isDeveloperModeEnabled {
            settings.minimumFetchInterval = 0
        } else {

            settings.minimumFetchInterval = minimumFetchInterval
        }
        remoteConfig.configSettings = settings
    }

    // МАРК: Fetch

    // Cache valid period
    private let expirationDuration: TimeInterval = 3600

    func fetchRemoteConfigValues(_ complete: (() -> Void)?) {
        remoteConfig.fetch(withExpirationDuration: expirationDuration) { [weak self] (status, error) in
            switch status {
                case .success:
                    print("Remote config fetched")
                    self?.remoteConfig.activate()
                default:
                    print("Remote config not fetched")
                    print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            complete?()
        }
    }

    // MARK: Values

    var isLatestAppVersionMandatory: Bool {
        return bool(forKey: .mandatory)
    }

    var latestAppVersion: String {
        return string(forKey: .latestAppVersion)
    }

    var appstoreLink: String {
        return string(forKey: .appstoreLink)
    }

    var endpointURL: String {
        return string(forKey: .endpointURL)
    }

    var statisticsPageURL: String {
        return string(forKey: .statisticsPageURL)
    }

    var locationIntervalMinutes: Int {
        return int(forKey: .locationIntervalMinutes)
    }

    var isStatisticsButtonVisible: Int {
        return int(forKey: .statisticsButtonVisible)
    }

    // MARK: Helpers

    private func bool(forKey key: RemoteConfigValueKey) -> Bool {
        return remoteConfig[key.rawValue].boolValue
    }

    private func string(forKey key: RemoteConfigValueKey) -> String {
        return remoteConfig[key.rawValue].stringValue ?? ""
    }

    private func double(forKey key: RemoteConfigValueKey) -> Double {
        if let numberValue = remoteConfig[key.rawValue].numberValue {
            return numberValue.doubleValue
        } else {
            return 0.0
        }
    }

    private func int(forKey key: RemoteConfigValueKey) -> Int {
        if let numberValue = remoteConfig[key.rawValue].numberValue {
            return numberValue.intValue
        } else {
            return 0
        }
    }

}
