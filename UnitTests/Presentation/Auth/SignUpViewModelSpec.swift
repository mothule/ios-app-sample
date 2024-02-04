//
//  SignUpViewModelSpec.swift
//  UnitTests
//
//  Created by mothule on 2023/11/11.
//

import Quick
import Nimble
import Combine
@testable import ios_auth_flow_sample

extension SignUpViewModel.AuthenticationState: Equatable {
    public static func == (lhs: SignUpViewModel.AuthenticationState, rhs: SignUpViewModel.AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.requesting, .requesting):
            return true
        case (.successful, .successful):
            return true
        case (.error(let lhError), .error(let rhError)):
            return lhError == rhError
        default:
            return false
        }
    }
}
extension DomainError: Equatable {
    public static func == (lhs: DomainError, rhs: DomainError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription &&
        lhs.code == rhs.code
    }
}

final class SignUpViewModelSpec: QuickSpec {
    override class func spec() {
        describe("SignUpViewModel") {
            var target: SignUpViewModel!
            var mockAuthRepository: AuthRepositoryMock!
            
            beforeEach {
                mockAuthRepository = AuthRepositoryMock()
                target = .init(authRepository: mockAuthRepository)
            }
            
            describe("メールアドレス入力バリデーション") {
                context("メールアドレスが未入力のとき") {
                    beforeEach {
                        target.input.email = ""
                    }
                    it("入力必須バリデーションエラーになる") {
                        expect(target.output.emailValidationError).toNot(beNil())
                        expect(target.output.emailValidationError?.errorDescription) == "メールアドレスを入力してください"
                    }
                }
                context("メールアドレスが入力済みのとき") {
                    beforeEach {
                        target.input.email = "asdf"
                    }
                    it("バリデーションエラーは空である") {
                        expect(target.output.emailValidationError).toNot(beNil())
                        expect(target.output.emailValidationError?.isSucceed).to(beTrue())
                    }
                }
            }
            
            describe("パスワード入力バリデーション") {
                context("パスワードが未入力のとき") {
                    beforeEach {
                        target.input.password = ""
                    }
                    it("入力必須バリデーションエラーになる") {
                        expect(target.output.passwordValidationError?.errorDescription) == "パスワードを入力してください"
                    }
                }
                
                context("パスワードが文字数不足のとき") {
                    beforeEach {
                        target.input.password = "1234567"
                    }
                    it("文字数不足バリデーションエラーになる") {
                        expect(target.output.passwordValidationError?.errorDescription) == "パスワードが短すぎます"
                    }
                }
                
                context("パスワードが文字数超過のとき") {
                    beforeEach {
                        target.input.password = String(repeating: "a", count: 65)
                    }
                    it("文字数オーバーバリデーションエラーになる") {
                        expect(target.output.passwordValidationError?.errorDescription) == "パスワードが長すぎます"
                    }
                }
                
                context("パスワードが想定値のとき(正常系)") {
                    let pattern: [String] = [
                        "12345678",
                        String(repeating: "a", count: 64)
                    ]
                    it("バリデーションエラーは空である") {
                        pattern.forEach {
                            target.input.password = $0
                            expect(target.output.passwordValidationError?.isSucceed).to(beTrue(), description: "エラー起きてる. patten: \($0)")
                        }
                    }
                }
            }
            
            describe("認証の有効状態") {
                context("バリデーションエラー有りのとき") {
                    it("認証は無効状態である") {
                        expect(target.output.isEnabledSignUp) == false
                    }
                }
                context("バリデーションエラー無し") {
                    beforeEach {
                        target.input.email = "address@domain.com"
                        target.input.password = "valid password"
                        mockAuthRepository.authenticateWithEmailHandler = { _ in
                            .init(accessToken: "valid-accesstoken")
                        }
                    }
                    it("認証は有効状態である") {
                        target.input.authenticateSubject.send()
                        expect(target.output.isEnabledSignUp) == true
                    }
                }
            }

            describe("認証プロセス") {
                var route: SignUpViewModel.Route?
                var dialogError: DomainError?
                var cancellables: Set<AnyCancellable> = []
                beforeEach {
                    route = nil
                    cancellables = []
                    target.output.routePublisher.sink { route = $0 }.store(in: &cancellables)
                    target.output.$dialogError.sink { dialogError = $0 }.store(in: &cancellables)
                    
                    target.input.email = "address@domain.com"
                    target.input.password = "valid password"
                }
                context("認証プロセスが成功したとき") {
                    beforeEach {
                        mockAuthRepository.authenticateWithEmailHandler = { _ in
                            return .init(accessToken: "valid-accesstoken")
                        }
                    }
                    it("View状態はウォークスルー遷移である") {
                        target.input.authenticateSubject.send()
                        expects(route).toEventually(equal(.navigateOnboardingWalkThrough))
                        expects(target.output.isShownProgress).toEventually(beFalse())
                    }
                }
                context("通信エラー発生したとき") {
                    beforeEach {
                        mockAuthRepository.authenticateWithEmailHandler = { _ in
                            throw RepositoryError.emptyApiAccessToken
                        }
                    }
                    it("View状態はエラー表示である") {
                        target.input.authenticateSubject.send()
                        expect(dialogError).toEventuallyNot(beNil())
                        if let error = dialogError {
                            expect(error).toEventually(equal(.fromRepositoryError(.emptyApiAccessToken)))
                        }
                    }
                }
                context("想定外エラー発生したとき") {
                    beforeEach {
                        mockAuthRepository.authenticateWithEmailHandler = { _ in
                            throw NSError(domain: "domain", code: -1001)
                        }
                    }
                    it("処理状態はエラー表示である") {
                        target.input.authenticateSubject.send()
                        expect(dialogError).toEventuallyNot(beNil())
                        if let error = dialogError {
                            expect(error).toEventually(equal(.unknown(error: error)))
                        }
                    }
                }
            }
        }
    }
}
