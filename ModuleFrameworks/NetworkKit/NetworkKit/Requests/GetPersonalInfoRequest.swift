//
//  GetPersonalInfoRequest.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 28.03.20.
//

import Foundation

public class GetPersonalInfoRequest: BaseAPIRequest {
    
    public override var httpMethod: HTTPMethod {
        return .get
    }
    
    public override var path: String {
        return "/personalinfo"
    }
    
    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }

    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}
