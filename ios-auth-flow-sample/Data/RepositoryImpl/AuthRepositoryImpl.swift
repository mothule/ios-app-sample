//
//  AuthRepositoryImpl.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Defaults

enum RepositoryError: Error {
    case emptyApiAccessToken
    case invalidApiAccessToken
}

protocol AuthRepository {
    func validToken() async throws
    func authenticate() async throws
}

struct AuthRepositoryImpl: AuthRepository {
    func authenticate() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Thread.sleep(forTimeInterval: 1)
//            continuation.resume(throwing: RepositoryError.emptyApiAccessToken)
            continuation.resume()
        }
    }
    
    func validToken() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Thread.sleep(forTimeInterval: 1)
            
            let token = Defaults[.apiAccessToken]
            guard token.isEmpty == false else {
                print("API access token is empty.")
                continuation.resume(throwing: RepositoryError.emptyApiAccessToken)
                return
            }
            
            let res = AuthValidResponse(
                accessToken: "valid-token",
                refreshToken: "valid-ref-token"
            )
            guard token == res.accessToken else {
                print("API access token is invalid.")
                continuation.resume(throwing: RepositoryError.invalidApiAccessToken)
                return
            }
            Defaults[.apiAccessToken] = token
            continuation.resume()
        }
    }
}
