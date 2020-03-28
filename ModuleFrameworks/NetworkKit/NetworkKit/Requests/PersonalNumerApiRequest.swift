//
//  PersonalNumerApiRequest.swift
//  NetworkKit
//
//  Created by Gandi Pirkov on 27.03.20.
//

import Foundation

public class PersonalNumerApiRequest: BaseAPIRequest {
    
    public convenience init(identificationNumber: String, age: Int, gender: String, preExistingConditions: String) {
        self.init(bodyJSONObject: ["identificationNumber": identificationNumber, "age": age, "gender": gender, "preExistingConditions": preExistingConditions])
    }
    
    public override var httpMethod: HTTPMethod {
        return .post
    }
    
    public override var path: String {
        return "/personalinfo"
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

