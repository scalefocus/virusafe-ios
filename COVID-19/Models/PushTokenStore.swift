//
//  PushTokenStore.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 29.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class PushTokenStore {

    // MARK: Singleton

    static var shared: PushTokenStore = PushTokenStore()
    private init() { }

    var fcmToken: String? {
        didSet {
            let dataDict: [String: String] = ["token": fcmToken ?? ""]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                            object: nil,
                                            userInfo: dataDict)
        }
    }

}
