//
//  AuthRepositoryImpl.swift
//  ios-app-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Defaults

struct AuthRepositoryImpl: AuthRepository {
    func authenticateWithEmail(credential: EmailAuthenticationCredential) async throws -> UserAccount {
        return try await withCheckedThrowingContinuation { continuation in
            Thread.sleep(forTimeInterval: 3)
//            continuation.resume(throwing: RepositoryError.emptyApiAccessToken)
            continuation.resume(returning: .init(accessToken: "asdfasdfasdf"))
        }
    }
    
    func validToken() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Thread.sleep(forTimeInterval: 2)
            
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
