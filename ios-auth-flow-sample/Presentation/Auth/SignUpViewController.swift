//
//  SignUpViewController.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import UIKit
import Combine
import CombineCocoa

class SignUpViewController: UIViewController {
    private let viewModel: SignUpViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    private lazy var signUpButton: UIButton = .init().tap {
        $0.setTitle("SIGN UP", for: .normal)
        $0.backgroundColor = .magenta
        $0.setTitleColor(.white, for: .normal)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var emailValidationResultLabel: UILabel = .init().tap {
        $0.textAlignment = .right
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 12.0)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var passwordValidationResultLabel: UILabel = .init().tap {
        $0.textAlignment = .right
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 12.0)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var emailTextField: UITextField = .init().tap {
        $0.placeholder = "xxx@xxx.xxx"
        $0.textContentType = .emailAddress
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.borderStyle = .roundedRect
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var passwordTextField: UITextField = .init().tap {
        $0.borderStyle = .roundedRect
        $0.placeholder = "8 ~ "
        $0.textContentType = .newPassword
        $0.passwordRules = .init(descriptor: "minlength: 8; required: lower; required: upper; required: digit; required: [-];")
        $0.isSecureTextEntry = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        
        let container: UIStackView = UIStackView().tap {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8.0
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        self.view.addSubview(container)
        
        let titleLabel: UILabel = .init().tap {
            $0.font = UIFont.boldSystemFont(ofSize: 24.0)
            $0.text = "SIGN UP"
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        container.addArrangedSubview(titleLabel)
        
        container.addArrangedSubview(.verticalSpacer(32))
        
        let emailLabel: UILabel = .init().tap {
            $0.text = "Email"
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        container.addArrangedSubview(emailLabel)
        
        container.addArrangedSubview(.verticalSpacer(4))

        container.addArrangedSubview(emailTextField)
        container.addArrangedSubview(emailValidationResultLabel)
        
        container.addArrangedSubview(.verticalSpacer(8))
        
        let passwordLabel: UILabel = .init().tap {
            $0.text = "Password"
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        container.addArrangedSubview(passwordLabel)
        
        container.addArrangedSubview(.verticalSpacer(4))
        
        container.addArrangedSubview(passwordTextField)
        container.addArrangedSubview(passwordValidationResultLabel)
        
        container.addArrangedSubview(.verticalSpacer(16))
        
        container.addArrangedSubview(signUpButton)
        
        self.view.addConstraints({() -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-16-[container]-16-|",
                metrics: nil,
                views: ["container": container]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[emailTextField]|",
                metrics: nil,
                views: ["emailTextField": emailTextField]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[emailValidationResultLabel]|",
                metrics: nil,
                views: ["emailValidationResultLabel": emailValidationResultLabel]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "V:[emailValidationResultLabel(12)]",
                metrics: nil,
                views: ["emailValidationResultLabel": emailValidationResultLabel]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[textField]|",
                metrics: nil,
                views: ["textField": passwordTextField]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[passwordValidationResultLabel]|",
                metrics: nil,
                views: ["passwordValidationResultLabel": passwordValidationResultLabel]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "V:[passwordValidationResultLabel(12)]",
                metrics: nil,
                views: ["passwordValidationResultLabel": passwordValidationResultLabel]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "V:[button(44)]",
                metrics: nil,
                views: ["button": signUpButton]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[button]|",
                metrics: nil,
                views: ["button": signUpButton]
            )
        }())
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: Self.self), #function)
        setBindings()
    }
    
    
    private func setBindings() {
        viewModel.$processState
            .compactMap {$0}
            .receive(on: RunLoop.main)
            .sink { [unowned self] state in
                switch state {
                case .authenticating:
                    break
                    
                case .navigateOnboardingWalkThrough:
                    dismissAndNavigateOnboardWalkThrough()
                    
                case .error(let signUpViewError):
                    let alert = UIAlertController(
                        title: "ERROR",
                        message: signUpViewError.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isEnabledSignUp
            .receive(on: RunLoop.main)
            .sink { [unowned self] isEnabled in
                signUpButton.isEnabled = isEnabled
                UIView.animate(withDuration: 0.3) {
                    self.signUpButton.backgroundColor = isEnabled ? .magenta : .gray
                }
            }
            .store(in: &cancellables)
        
        viewModel.$emailValidationError
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: emailValidationResultLabel)
            .store(in: &cancellables)
        
        viewModel.$passwordValidationError
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: passwordValidationResultLabel)
            .store(in: &cancellables)
        
        
        // Bindings View → ViewModel
        signUpButton.tapPublisher.sink { [unowned self] _ in
            viewModel.authenticate()
        }
        .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTextField)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text })
            .replaceNil(with: "")
            .assign(to: &viewModel.$email)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text })
            .replaceNil(with: "")
            .assign(to: &viewModel.$password)
        
    }
    
    private func dismissAndNavigateOnboardWalkThrough() {
        let parent = parent
        view.removeFromSuperview()
        removeFromParent()
        didMove(toParent: parent)
        
        // TODO: show walk through
    }
}

import SwiftUI
struct SignUpViewController_Preview: PreviewProvider {
    struct Wrapper: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            SignUpViewController()
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
