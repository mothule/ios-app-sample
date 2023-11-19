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
    enum SignUpState {
        /// 認証APIリクエスト中
        case authenticating
        /// 認証成功した
        case successful
        /// 認証失敗
        case error(SignUpViewError)
    }
    
    enum Route {
        /// ウォークスルーへ遷移
        case navigateOnboardingWalkThrough
    }
    
    // INPUT
    @Published var email: String = ""
    @Published var password: String = ""
    
    // INTERNAL
    @Published private var signUpState: SignUpState?

    // OUTPUT
    @Published private(set) var isEnabledSignUp: Bool = false
    @Published private(set) var emailValidationError: String?
    @Published private(set) var passwordValidationError: String?
    @Published private(set) var isShownProgress: Bool = false
    @Published private(set) var route: Route?
    @Published private(set) var dialogError: SignUpViewError?
    
    private var cancellables: Set<AnyCancellable> = []
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        setBindings()
    }
    
    func authenticate() {
        Task { [weak self] in
            do {
                self?.signUpState = .authenticating
                try await self?.authRepository.authenticate()
                self?.signUpState = .successful
                
            } catch let error as RepositoryError {
                self?.signUpState = .error(.apiError(error))
                
            } catch {
                self?.signUpState = .error(.unknown)
            }
        }
    }
    
    private func setBindings() {
        // TODO: 汎用バリデーションを導入検討
        // Email → Email Validation Error
        $email
            .dropFirst() // 初期値はユーザ無関係なので破棄
            .map { email in
                email.isEmpty ? "email is required" : ""
            }
            .assign(to: &$emailValidationError)
        
        // TODO: 汎用バリデーションを導入検討
        // Password → Password Validation Error
        $password
            .dropFirst() // 初期値はユーザ無関係なので破棄
            .map { password in
                if password.isEmpty {
                    return "Required password"
                } else if password.count < 8 {
                    return "Password length should higher 7 length"
                } else if password.count > 64 {
                    return "Password length should lower 65 length"
                } else {
                    return ""
                }
            }
            .assign(to: &$passwordValidationError)
        
        
        // バリデーションエラーが1件もない and 処理状態が初期状態またはエラー なら認証ボタンを有効化
        // (Email Validation Error is Empty & Password Validation Error is Empty) & SignUp State nil or error = isEnabledSignUp
        Publishers.CombineLatest(
            Publishers.CombineLatest($emailValidationError, $passwordValidationError)
                .map {
                    guard let emailError = $0 else { return false }
                    guard let passwordError = $1 else { return false }
                    return emailError.isEmpty && passwordError.isEmpty
                }
            , $signUpState
                .map {
                    switch $0 {
                    case .none, .error: return true
                    default: return false
                    }
                }
        )
        .map { $0 && $1 }
        .assign(to: &$isEnabledSignUp)
        
        // SignUp State → isShownProgress
        $signUpState
            .compactMap { $0 }
            .map { state in
                if case .authenticating = state { return true }
                else { return false }
            }
            .assign(to: &$isShownProgress)
        
        // SignUp State is successful → Rouote
        //              is error → Dialog Error
        $signUpState
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [unowned self] state in
                switch state {
                case .authenticating: break
                case .successful:
                    route = .navigateOnboardingWalkThrough
                case .error(let error):
                    dialogError = error
                }
            }
            .store(in: &cancellables)
    }
}
