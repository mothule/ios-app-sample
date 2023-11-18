//
//  SignUpViewModel.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Combine

enum SignUpViewError: Error {
    case formValidationError(EmailAuthenticationValidationResult)
    case apiError(RepositoryError)
    case unknown
}


// TODO: 汎用フォームバリデーション用エラーに差し替える
enum EmailAuthenticationValidationResult: Error {
    case successful
    case emailRequired
    case emailInvalidFormat
    case passwordRequired
    case passwordMinLength
    case passwordMaxLength
}

class SignUpViewModel {
    enum ProcessState {
        /// 認証APIリクエスト中
        case authenticating
        /// ウォークスルーへ遷移
        case navigateOnboardingWalkThrough
        /// 認証失敗
        case error(SignUpViewError)
    }
    
    // TODO: input 
    // INPUT
    @Published var email: String = ""
    @Published var password: String = ""

    // TODO: struct Output
    // OUTPUT
    @Published var processState: ProcessState?
    @Published var isEnabledSignUp: Bool = false
    @Published var emailValidationError: String? // TODO: replace to enum
    @Published var passwordValidationError: String?
    
    private var cancellables: Set<AnyCancellable> = []
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        setBindings()
    }
    
    func authenticate() {
        Task { [weak self] in
            do {
                self?.processState = .authenticating
                try await self?.authRepository.authenticate()
                self?.processState = .navigateOnboardingWalkThrough
                
            } catch let error as RepositoryError {
                self?.processState = .error(.apiError(error))
                
            } catch {
                self?.processState = .error(.unknown)
            }
        }
    }
    
    private func setBindings() {
        $email
            .dropFirst() // 初期値はユーザ無関係なので破棄
            .map { email in
                email.isEmpty ? "email is required" : ""
            }
            .assign(to: &$emailValidationError)
        
        $password
            .dropFirst() // 初期値はユーザ無関係なので破棄
            .map { password in
                if password.isEmpty {
                    return "Required password"
                } else if password.count < 8 {
                    return "Password length should higher 8 length"
                } else if password.count > 64 {
                    return "Password length should lower 63 length"
                } else {
                    return ""
                }
            }
            .assign(to: &$passwordValidationError)
        
        // バリデーションエラーが1件もない and 処理状態が初期状態またはエラー なら認証ボタンを有効化
        Publishers.CombineLatest(
            Publishers.CombineLatest($emailValidationError, $passwordValidationError)
                .map {
                    guard let emailError = $0 else { return false }
                    guard let passwordError = $1 else { return false }
                    return emailError.isEmpty && passwordError.isEmpty
                }
            , $processState
                .map {
                    switch $0 {
                    case .none, .error: return true
                    default: return false
                    }
                }
        )
        .map { $0 && $1 }
        .assign(to: &$isEnabledSignUp)
    }
}
