//
//  SignUpViewModel.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Combine

extension SignUpViewModel {
    // TODO: 汎用Validatorの導入検討. ValidatedPropertyKitは検証条件毎(.isEmpty, isEmail)にエラー情報を付与できない. またDefaultsと宣言が衝突してるエラーが発生する
    struct ValidationResult {
        var errorDescription: String?
        
        var isSucceed: Bool { errorDescription?.isEmpty ?? true }
        
        static func success() -> Self {
            .init(errorDescription: nil)
        }
        static func emailRequired() -> Self {
            .init(errorDescription: "メールアドレスを入力してください")
        }
        static func emailInvalidFormat() -> Self {
            .init(errorDescription: "無効なメールアドレスです")
        }
        static func passwordRequired() -> Self {
            .init(errorDescription: "パスワードを入力してください")
        }
        static func passwordMinLength() -> Self {
            .init(errorDescription: "パスワードが短すぎます")
        }
        static func passwordMaxLength() -> Self {
            .init(errorDescription: "パスワードが長すぎます")
        }
    }
}


class SignUpViewModel {
    enum AuthenticationState {
        case requesting
        case successful
        case error(DomainError)
    }
    
    enum Route {
        /// ウォークスルーへ遷移
        case navigateOnboardingWalkThrough
    }
    
    class Input {
        @Published 
        var email: String?
        
        @Published 
        var password: String?
        
        var authenticateSubject: PassthroughSubject<Void, Never> = .init()
        
        init(email: String? = nil, password: String? = nil, authenticateSubject: PassthroughSubject<Void, Never> = .init()) {
            self.email = email
            self.password = password
            self.authenticateSubject = authenticateSubject
        }
    }
    
    class Output {
        @Published var isEnabledSignUp: Bool = false
        @Published var emailValidationError: ValidationResult?
        @Published var passwordValidationError: ValidationResult?
        @Published var isShownProgress: Bool = false
        @Published var dialogError: DomainError?
        
        fileprivate var routeSubject: PassthroughSubject<Route, Never> = .init()
        var routePublisher: any Publisher<Route, Never> { routeSubject }
    }
    
    var input: Input = .init()
    private(set) var output: Output = .init()
    // INTERNAL
    @Published private var authState: AuthenticationState?
    
    private var cancellables: Set<AnyCancellable> = []
    private let userAuthenticationUsecase: UserAuthenticationUsecase
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.userAuthenticationUsecase = .init(authRepository: authRepository)
        setBindings()
    }
    
    private func setBindings() {
        // Email → Email Validation Error
        input.$email
            .compactMap { $0 } // ignore nil
            .map { email in
                email.isEmpty ? .emailRequired() : .success()
            }
            .assign(to: &output.$emailValidationError)
        
        // Password → Password Validation Error
        input.$password
            .compactMap { $0 } // ignore nil
            .map { password in
                if password.isEmpty {
                    return .passwordRequired()
                } else if password.count < 8 {
                    return .passwordMinLength()
                } else if password.count > 64 {
                    return .passwordMaxLength()
                } else {
                    return .success()
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
                guard let email = $0, let password = $1 else { return false }
                return email.isSucceed && password.isSucceed
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
                let userAccount = try await self?.userAuthenticationUsecase.signUpWithEmail(credential: .init(email: email, password: password))
                self?.authState = .successful
                
            } catch let error as DomainError {
                self?.authState = .error(error)
                
            } catch {
                fatalError("Program Exception: 起きうる全例外をキャッチできていない. \(error)")
            }
        }
    }
}
