//
//  UserAuthenticationUsecase.swift
//  ios-app-sample
//  
//  Created by mothule on 2024/01/21
//  
//

import Foundation

struct UserAuthenticationUsecase {
    var authRepository: AuthRepository
    
    /// メール認証でサインアップする
    func signUpWithEmail(credential: EmailAuthenticationCredential) async throws -> UserAccount {
        do {
            return try await authRepository.authenticateWithEmail(credential: credential)
        } catch let error as RepositoryError {
            throw DomainError.fromRepositoryError(error)
        } catch {
            throw DomainError.unknown(error: error)
        }
    }
    
    /// メール認証でサインインする
    func signInWithEmail(credential: EmailAuthenticationCredential) async throws -> UserAccount {
        do {
            return try await authRepository.authenticateWithEmail(credential: credential)
        } catch let error as RepositoryError {
            throw DomainError.fromRepositoryError(error)
        } catch {
            throw DomainError.unknown(error: error)
        }
    }
}
