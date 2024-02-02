//
//  ApiClient.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation

protocol HttpRequestable: Encodable {
    var url: URL { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
    var timeoutInterval: TimeInterval? { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }
}

protocol HttpResponsable: Decodable {
    
    
}

struct ApiClientConfiguration {
    var cachePolicy: URLRequest.CachePolicy
    var timeoutInterval: TimeInterval
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    
    static var `default`: Self {
        .init(
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 30.0,
            dateDecodingStrategy: .deferredToDate
        )
    }
}

protocol ApiClient {
    func sendHttpRequest<Request: HttpRequestable, Response: HttpResponsable>(_ request: Request) async throws -> Response
}

struct ApiClientImpl: ApiClient {
    
    let session: URLSession
    let configuration: ApiClientConfiguration
    
    init(session: URLSession = .shared, configuration: ApiClientConfiguration = .default) {
        self.session = session
        self.configuration = configuration
    }
    
    func sendHttpRequest<Request, Response>(_ request: Request) async throws -> Response where Request: HttpRequestable, Response: HttpResponsable {
        
        let urlRequest = URLRequest(
            url: request.url,
            cachePolicy: request.cachePolicy ?? configuration.cachePolicy,
            timeoutInterval: request.timeoutInterval ?? configuration.timeoutInterval
        )
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                // TODO: throw translated error
                fatalError()
            }
            guard 200..<300 ~= httpUrlResponse.statusCode else {
                // without Success
                // TODO: throw translated error
                fatalError()
            }
            
            // Success
            return try JSONDecoder().tap {
                $0.dateDecodingStrategy = request.dateDecodingStrategy ?? configuration.dateDecodingStrategy
            }.decode(Response.self, from: data)
                
                
        } catch {
            // TODO: throw translated error
            fatalError()
        }
    }
    
}
