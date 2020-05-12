//
//  DeletePersonalInformationRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 11.05.20.
//

import Foundation

public class DeletePersonalInformationRequest: BaseAPIRequest {

    public override var httpMethod: HTTPMethod {
        return .delete
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
