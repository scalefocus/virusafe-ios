//
//  GpsApiRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//

import Foundation

public class GpsApiRequest: BaseAPIRequest {
    private var phoneNumber: String = ""
    private var bluetoothId: String = ""
    
    public convenience init(location: UserLocation, phoneNumber: String, timestamp: String, bluetoothId: String = "0") {
        let jsonDict: [String: Any] = [
            "location": location.asDictionary(),
            "timestamp": timestamp
        ]
        self.init(bodyJSONObject: jsonDict)
        self.phoneNumber = phoneNumber
        self.bluetoothId = bluetoothId
    }

    public override var httpMethod: HTTPMethod {
        return .post
    }

    public override var path: String {
        return "/location/gps"
    }

    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var headers: [String: String] {
        var defaultHeaders = super.headers
        defaultHeaders["PhoneNumber"] = phoneNumber
        defaultHeaders["BluetoothId"] = bluetoothId
        return defaultHeaders
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }

    public override var shouldWorkInBackground: Bool {
        return true
    }
}
