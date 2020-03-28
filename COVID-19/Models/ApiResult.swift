//
//  ApiResult.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 26.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

enum ApiResult<Success> {
    case success(Success?)
    case failure(ApiError)
}

enum ApiError: Error {
    case tooManyRequests(reapeatAfter: Int) // Seconds
    case server // returned status code is in range 400...599
    case general // any network error
    case invalidToken
}
