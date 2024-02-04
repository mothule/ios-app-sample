//
//  ApiClient.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation

// MARK: - Request

enum HttpMethod: String {
    case get
    case post
    case put
    case delete
}

protocol HttpRequestable {
    associatedtype Response: HttpResponsable
    
    var url: URL? { get }
    var httpMethod: HttpMethod { get }
    var httpHeaderFields: [String: String]? { get }
    
    /// リクエスト毎のキャッシュポリシー. nilならConfigurationの値を使う
    var overwriteCachePolicy: URLRequest.CachePolicy? { get }
    
    /// リクエスト毎のタイムアウト指定。nilならConfigurationの値を使う
    var overwriteRequestTimeoutInterval: TimeInterval? { get }
    
    /// レスポンスボディからレスポンスモデルへデコードする
    func decodeResponseBody(data: Data) throws -> Response
}

// MARK: - Response

protocol HttpResponsable: Decodable {}

// MARK: - Configuration

struct ApiClientConfiguration {
    var cachePolicy: URLRequest.CachePolicy
    var timeoutInterval: TimeInterval
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    static var `default`: Self {
        .init(
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 60.0,
            dateDecodingStrategy: .deferredToDate
        )
    }
}

// MARK: - Error

enum ApiError: LocalizedError & CustomNSError {
    /// 通信プロセスや通信経路上に問題が発生
    case networkError
    /// リクエスト処理でエラー
    case requestError
    /// レスポンス処理でエラー
    case responseError
    /// HTTPステータスエラー
    case httpError
    
    case unknown(Error)
}

// MARK: - Client

/// サーバサイドAPIと通信するためにクライアントサイドで利用する通信方法を公開する.
protocol ApiClient {
    /// HTTPリクエストの送信.
    /// - Parameters:
    ///     - request: HTTPリクエスト
    /// - Returns: リクエストに指定された方法でデコードされたペイロードを含むレスポンス
    /// - Throws: ApiError
    func sendHttpRequest<Request: HttpRequestable>(_ request: Request) async throws -> Request.Response
}

extension URLRequest: Tappable {}
extension URLComponents: Tappable {}

struct ApiClientImpl: ApiClient {
    let session: URLSession
    let configuration: ApiClientConfiguration
    
    init(session: URLSession = .shared, configuration: ApiClientConfiguration = .default) {
        self.session = session
        self.configuration = configuration
    }
    
    func sendHttpRequest<Request: HttpRequestable>(_ request: Request) async throws -> Request.Response {
        guard let url = request.url else { throw ApiError.requestError }
        
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: request.overwriteCachePolicy ?? configuration.cachePolicy,
            timeoutInterval: request.overwriteRequestTimeoutInterval ?? configuration.timeoutInterval
        ).tap {
            $0.httpMethod = request.httpMethod.rawValue
        }
        print(urlRequest.debugDescription)
        
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                // TODO: エラー情報を追加する
                throw ApiError.responseError
            }
            guard 200..<300 ~= httpUrlResponse.statusCode else {
                // TODO: エラー情報を追加する
                throw ApiError.httpError
            }
            
            // Debug
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            
            // Success
            return try request.decodeResponseBody(data: data)
            
        } catch let error as ApiError {
            throw error
            
        } catch let error {
            throw ApiError.unknown(error)
        }
    }
    
}
