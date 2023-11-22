//
//  SignUpViewModel.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Combine

struct SignUpViewError: LocalizedError {
    var errorDescription: String?
    
    static func formValidationError(result: EmailAuthenticationValidationResult) -> Self {
        let description = switch result {
        case .successful: ""
        case .emailRequired: "メールアドレスを入力してください"
        case .emailInvalidFormat: "無効なメールアドレスです"
        case .passwordRequired: "パスワードを入力してください"
        case .passwordMinLength: "パスワードが短すぎます"
        case .passwordMaxLength: "パスワードが長すぎます"
        }
        return .init(errorDescription: description)
    }
    
    static func apiError(repositoryError: RepositoryError) -> Self {
        let description = switch repositoryError {
        case .emptyApiAccessToken: "APIアクセストークンが空です"
        case .invalidApiAccessToken: "無効なアクセストークンです"
        }
        return .init(errorDescription: description)
    }
    
    static func unknown() -> Self {
        .init(errorDescription: "不明なエラーが発生しました")
    }
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
    enum AuthenticationState {
        case requesting
        case successful
        case error(SignUpViewError)
    }
    
    enum Route {
        /// ウォークスルーへ遷移
        case navigateOnboardingWalkThrough
    }
    
    class Input {
        @Published var email: String?
        @Published var password: String?
        var authenticateSubject: PassthroughSubject<Void, Never> = .init()
    }
    
    class Output {
        @Published var isEnabledSignUp: Bool = false
        @Published var emailValidationError: String?
        @Published var passwordValidationError: String?
        @Published var isShownProgress: Bool = false
        @Published var dialogError: SignUpViewError?
        
        fileprivate var routeSubject: PassthroughSubject<Route, Never> = .init()
        var routePublisher: any Publisher<Route, Never> { routeSubject }
    }
    
    var input: Input = .init()
    private(set) var output: Output = .init()
    // INTERNAL
    @Published private var authState: AuthenticationState?
    
    private var cancellables: Set<AnyCancellable> = []
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        setBindings()
    }
    
    private func setBindings() {
        // TODO: 汎用バリデーションを導入検討
        // TODO: SignUpViewError形式で返す
        // Email → Email Validation Error
        input.$email
            .compactMap { $0 }
            .map { email in
                email.isEmpty ? "email is required" : ""
            }
            .assign(to: &output.$emailValidationError)
        
        // TODO: 汎用バリデーションを導入検討
        // TODO: SignUpViewError形式で返す
        // Password → Password Validation Error
        input.$password
            .compactMap { $0 }
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
            .assign(to: &output.$passwordValidationError)
        
        input.authenticateSubject
            .sink { [unowned self] in
                authenticate()
            }
            .store(in: &cancellables)
        
        // バリデーションエラーが1件もない and 処理状態が初期状態またはエラー なら認証ボタンを有効化
        // (Email Validation Error is Empty & Password Validation Error is Empty) & SignUp State nil or error = isEnabledSignUp
        Publishers.CombineLatest(
            Publishers.CombineLatest(
                output.$emailValidationError, output.$passwordValidationError
            )
            .map {
                guard let emailError = $0 else { return false }
                guard let passwordError = $1 else { return false }
                return emailError.isEmpty && passwordError.isEmpty
            }
            , $authState
                .map {
                    switch $0 {
                    case .none, .error: return true
                    default: return false
                    }
                }
        )
        .map { $0 && $1 }
        .assign(to: &output.$isEnabledSignUp)
        
        // SignUp State → isShownProgress
        $authState
            .compactMap { $0 }
            .map { state in
                if case .requesting = state { return true }
                else { return false }
            }
            .assign(to: &output.$isShownProgress)
        
        // SignUp State is successful → Rouote
        //              is error → Dialog Error
        $authState
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [unowned self] state in
                switch state {
                case .requesting: break
                case .successful:
                    output.routeSubject.send(.navigateOnboardingWalkThrough)
                case .error(let error):
                    output.dialogError = error
                }
            }
            .store(in: &cancellables)
    }
    
    private func authenticate() {
        guard let email = input.email,
              let password = input.password else {
            preconditionFailure("Program Exception.")
        }
        
        Task { [weak self] in
            do {
                self?.authState = .requesting
                try await self?.authRepository.authenticate(
                    email: email,
                    password: password
                )
                self?.authState = .successful
                
            } catch let error as RepositoryError {
                self?.authState = .error(.apiError(repositoryError: error))
                
            } catch {
                self?.authState = .error(.unknown())
            }
        }
    }
}
