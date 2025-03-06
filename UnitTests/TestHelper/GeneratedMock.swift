///
/// @Generated by Mockolo
///

#if DEBUG

import Foundation
@testable import ios_app_sample


final class AuthRepositoryMock: AuthRepository {
    init() { }


    private(set) var validTokenCallCount = 0
    var validTokenHandler: (() async throws -> ())?
    func validToken() async throws {
        validTokenCallCount += 1
        if let validTokenHandler = validTokenHandler {
            try await validTokenHandler()
        }
        
    }

    private(set) var authenticateWithEmailCallCount = 0
    var authenticateWithEmailHandler: ((EmailAuthenticationCredential) async throws -> UserAccount)?
    func authenticateWithEmail(credential: EmailAuthenticationCredential) async throws -> UserAccount {
        authenticateWithEmailCallCount += 1
        if let authenticateWithEmailHandler = authenticateWithEmailHandler {
            return try await authenticateWithEmailHandler(credential)
        }
        fatalError("authenticateWithEmailHandler returns can't have a default value thus its handler must be set")
    }
}



#endif