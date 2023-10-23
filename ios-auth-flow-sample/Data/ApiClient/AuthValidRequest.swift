//
//  AuthValidRequest.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation

protocol ApiRequestable: Encodable {
    
}

protocol ApiResponsable: Decodable {
    
}

struct AuthValidRequest: ApiRequestable {
    
}

struct AuthValidResponse: ApiResponsable {
    var accessToken: String
    var refreshToken: String
}
