//
//  SignUpViewModelSpec.swift
//  UnitTests
//
//  Created by mothule on 2023/11/11.
//

import Quick
import Nimble
@testable import ios_auth_flow_sample

extension SignUpViewModel.ProcessState: Equatable {
    public static func == (lhs: SignUpViewModel.ProcessState, rhs: SignUpViewModel.ProcessState) -> Bool {
        switch (lhs, rhs) {
        case (.authenticating, .authenticating):
            return true
        case (.navigateOnboardingWalkThrough, .navigateOnboardingWalkThrough):
            return true
        case (.error(let lhError), .error(let rhError)):
            return lhError == rhError
        default:
            return false
        }
    }
}
extension SignUpViewError: Equatable {
    public static func == (lhs: SignUpViewError, rhs: SignUpViewError) -> Bool {
        switch (lhs, rhs) {
        case (.formValidationError(let lhError), .formValidationError(let rhError)):
            return lhError == rhError
        case (.apiError(let lhError), .apiError(let rhError)):
            return lhError == rhError
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
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
                        target.email = ""
                    }
                    it("入力必須バリデーションエラーになる") {
                        expect(target.emailValidationError).toNot(beNil())
                        expect(target.emailValidationError) == "email is required"
                    }
                }
                context("メールアドレスが入力済みのとき") {
                    beforeEach {
                        target.email = "asdf"
                    }
                    it("バリデーションエラーは空である") {
                        expect(target.emailValidationError).toNot(beNil())
                        expect(target.emailValidationError).to(beEmpty())
                    }
                }
            }
            
            describe("パスワード入力バリデーション") {
                context("パスワードが未入力のとき") {
                    beforeEach {
                        target.password = ""
                    }
                    it("入力必須バリデーションエラーになる") {
                        expect(target.passwordValidationError) == "Required password"
                    }
                }
                
                context("パスワードが文字数不足のとき") {
                    beforeEach {
                        target.password = "1234567"
                    }
                    it("文字数不足バリデーションエラーになる") {
                        expect(target.passwordValidationError) == "Password length should higher 7 length"
                    }
                }
                
                context("パスワードが文字数超過のとき") {
                    beforeEach {
                        target.password = String(repeating: "a", count: 65)
                    }
                    it("文字数オーバーバリデーションエラーになる") {
                        expect(target.passwordValidationError) == "Password length should lower 65 length"
                    }
                }
                
                context("パスワードが想定値のとき(正常系)") {
                    let pattern: [String] = [
                        "12345678",
                        String(repeating: "a", count: 64)
                    ]
                    it("バリデーションエラーは空である") {
                        pattern.forEach {
                            target.password = $0
                            expect(target.passwordValidationError).to(beEmpty(), description: "エラー起きてる. patten: \($0)")
                        }
                    }
                }
            }
            
            describe("認証の有効状態") {
                context("バリデーションエラー有りのとき") {
                    it("認証は無効状態である") {
                        expect(target.isEnabledSignUp) == false
                    }
                }
                context("バリデーションエラー無し") {
                    beforeEach {
                        target.email = "address@domain.com"
                        target.password = "valid password"
                    }
                    it("認証は有効状態である") {
                        target.authenticate()
                        expect(target.isEnabledSignUp) == true
                    }
                }
            }

            describe("認証プロセス") {
                beforeEach {
                    target.email = "address@domain.com"
                    target.password = "valid password"
                }
                context("認証プロセスが成功したとき") {
                    it("処理状態はウォークスルー遷移である") {
                        target.authenticate()
                        expects(target.processState).toEventually(equal(.navigateOnboardingWalkThrough))
                    }
                }
                
                context("通信エラー発生したとき") {
                    beforeEach {
                        mockAuthRepository.authenticateHandler = {
                            throw RepositoryError.emptyApiAccessToken
                        }
                    }
                    it("処理状態はエラー表示である") {
                        target.authenticate()
                        expect(target.processState).toEventuallyNot(beNil())
                        expect(target.processState!).toEventually(equal(.error(.apiError(.emptyApiAccessToken))))
                    }
                }
                
                context("想定外エラー発生したとき") {
                    beforeEach {
                        mockAuthRepository.authenticateHandler = {
                            throw NSError(domain: "domain", code: -1001)
                        }
                    }
                    it("処理状態はエラー表示である") {
                        target.authenticate()
                        expect(target.processState).toEventuallyNot(beNil())
                        expect(target.processState!).toEventually(equal(.error(.unknown)))
                    }
                }
            }
        }
    }
}
