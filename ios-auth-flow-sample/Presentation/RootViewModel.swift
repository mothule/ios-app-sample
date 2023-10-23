//
//  RootViewModel.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Combine

class RootViewModel {
    enum ProcState {
        case entry
        case signIn
        case signUp
        case main
    }
    
    @Published var procState: ProcState?
    private var cancellables: Set<AnyCancellable> = []
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        setupBindings()
    }
    
    private func setupBindings() {
        $procState
            .print("RootViewModel.procState")
            .compactMap{
                if case .entry = $0 { return ProcState.entry }
                else { return nil }
            }
            .sink { [unowned self] _ in
                Task {
                    do {
                        try await authRepository.validToken()
                        procState = .main
                    } catch let error as RepositoryError {
                        switch error {
                        case .emptyApiAccessToken:
                            procState = .signUp
                        case .invalidApiAccessToken:
                            procState = .signIn
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func validUserIdentifier() {
        procState = .entry
    }
}
