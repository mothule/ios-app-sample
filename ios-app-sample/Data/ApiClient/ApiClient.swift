////
////  ApiClient.swift
////  ios-app-sample
////
////  Created by mothule on 2023/09/08.
////

import Foundation
import ApiSession

protocol ApiClientProtocol {
    func sendHttpRequest<T: ApiRequest>(_ request: T) async throws -> T.Response
}

class ApiClient: ApiClientProtocol {
    static var shared: ApiClientProtocol = ApiClient()
    
    let session: ApiSession.Session
    let adapter: URLSessionAdapter
    let sessionConfig: URLSessionConfiguration
    
    private init() {
        sessionConfig = .default.tap { c in
            // timeout
            c.timeoutIntervalForRequest = 60.0
            c.timeoutIntervalForResource = 300.0 // 5 mins
            
            // cache
            c.requestCachePolicy = .useProtocolCachePolicy
            c.urlCache = .shared
        }
        
        
        adapter = URLSession(
            configuration: sessionConfig,
            delegate: nil,
            delegateQueue: .main
        )
        
        session = .init(session: adapter)
    }
    
    func sendHttpRequest<T>(_ request: T) async throws -> T.Response where T: ApiRequest {
        try await session.sendHttpRequest(request)
    }
}
