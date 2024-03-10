//
//  AuthValidRequest.swift
//  ios-app-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import ApiSession

struct AuthValidRequest: AuthApiRequest {
    typealias SuccessBodyResponse = AuthValidResponse
    
    var path: String { "/v2/auth-validation" }
    var httpMethod: HttpMethod { .post }
    
    var accessToken: String
    var refreshToken: String
    
    var queryItems: [URLQueryItem] {
        [
            .init(name: "accessToken", value: accessToken),
            .init(name: "refreshToken", value: refreshToken)
        ]
    }
}

struct AuthValidResponse: ApiSession.BodyResponsable  {
    var accessToken: String
    var refreshToken: String
}
