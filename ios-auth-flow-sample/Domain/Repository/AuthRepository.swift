//
//  AuthRepository.swift
//  ios-auth-flow-sample
//  
//  Created by mothule on 2024/01/21
//  
//

import Foundation

/// @mockable
protocol AuthRepository {
    func validToken() async throws
    func authenticateWithEmail(credential: EmailAuthenticationCredential) async throws -> UserAccount
}
