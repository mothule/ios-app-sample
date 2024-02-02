//
//  AuthValidRequest.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation

struct AuthValidRequest {
}

struct AuthValidResponse: HttpResponsable {
    var accessToken: String
    var refreshToken: String
}
