//
//  Request.swift
//  ios-auth-flow-sample
//  
//  Created by mothule on 2024/02/17
//  
//

import Foundation
import ApiSession

// MARK: - ApiRequest
protocol ApiRequest: HttpRequestable where ErrorBodyResponse == ApiErrorBody {
    var sharedHttpHeaderFields: [String: String] { get }
    var additionalHttpHeaderFields: [String: String] { get }
    var path: String { get }
    var domain: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension URLComponents: Tappable {}

extension ApiRequest {
    var domain: String { "https://api.mothule.com" }
    
    var url: URL? { 
        URLComponents(string: domain)?.tap { c in
            c.path = path
            c.queryItems = queryItems
        }.url
    }
    
    var httpBody: Data? { nil }
    
    var sharedHttpHeaderFields: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    var additionalHttpHeaderFields: [String: String] { [:] }
    
    var httpHeaderFields: [String: String]? {
        sharedHttpHeaderFields.merging(
            additionalHttpHeaderFields,
            uniquingKeysWith: { _, r in r }
        )
    }
    var cachePolicy: URLRequest.CachePolicy? { nil }
    var requestTimeoutInterval: TimeInterval? { nil }
    
    func decodeResponseBody(data: Data) throws -> SuccessBodyResponse {
        try JSONDecoder().decode(SuccessBodyResponse.self, from: data)
    }
    
    func decodeErrorResponseBody(data: Data) throws -> ErrorBodyResponse {
        try JSONDecoder().decode(ErrorBodyResponse.self, from: data)
    }
}


// MARK: - AuthApiRequest
protocol AuthApiRequest: ApiRequest {
    var accessToken: String { get }
}

extension AuthApiRequest {
    var httpHeaderFields: [String: String]? {
        sharedHttpHeaderFields.merging(
            ["Authorization": accessToken],
            uniquingKeysWith: { _, r in r }
        )
        .merging(
            additionalHttpHeaderFields,
            uniquingKeysWith: {_, r in r }
        )
    }
}

// MARK: - API Error body
struct ApiErrorBody: BodyResponsable {
    var code: String
    var message: String
}

