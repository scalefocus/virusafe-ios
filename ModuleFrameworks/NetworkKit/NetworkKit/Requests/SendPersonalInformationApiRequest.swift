//
//  PersonalNumerApiRequest.swift
//  NetworkKit
//
//  Created by Gandi Pirkov on 27.03.20.
//

import Foundation

public class SendPersonalInformationApiRequest: BaseAPIRequest {
    
    public convenience init(identificationNumber: String?, age: Int?, gender: String?, preExistingConditions: String?) {
        var jsonObject: [String: Any] = [:]
        if let identificationNumber = identificationNumber {
            jsonObject["identificationNumber"] = identificationNumber
        }
        if let age = age {
            jsonObject["age"] = age
        }
        if let gender = gender {
            jsonObject["gender"] = gender
        }
        if let preExistingConditions = preExistingConditions {
            jsonObject["preExistingConditions"] = preExistingConditions
        }
        self.init(bodyJSONObject: jsonObject)
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

