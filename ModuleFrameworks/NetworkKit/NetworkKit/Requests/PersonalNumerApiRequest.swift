//
//  PersonalNumerApiRequest.swift
//  NetworkKit
//
//  Created by Gandi Pirkov on 27.03.20.
//

import Foundation

public class PersonalNumerApiRequest: BaseAPIRequest {
    
    public convenience init(personalNumber: String) {
        self.init(bodyJSONObject: ["personalNumber": personalNumber])
    }
    
    public override var httpMethod: HTTPMethod {
        return .post
    }
    
    public override var path: String {
        return "/personalNumber"
    }
    
    public override var baseUrl: BaseURL {
        return APIManager.shared.baseURLs.base
    }
    
    
    public override var baseUrlPort: Int? {
        return APIManager.shared.baseURLs.port
    }
    
    public override var authorizationRequirement: AuthorizationRequirement {
        return .none
    }
}

