//
//  SignUpViewController.swift
//  ios-auth-flow-sample
//
//  Created by Motoki Kawakami on 2023/09/08.
//

import UIKit
import Combine

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
        // setup input event hooks
        signUpButton.addTarget(self, action: #selector(onTouchedSignUpButton(_:)), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChangeNotification(_:)), name: UITextField.textDidChangeNotification, object: emailTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChangeNotification(_:)), name: UITextField.textDidChangeNotification, object: passwordTextField)
        
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
                signUpButton.backgroundColor = isEnabled ? .magenta : .gray
            }
            .store(in: &cancellables)
        
        viewModel.$emailValidationError
            .receive(on: RunLoop.main)
            .sink { [unowned self] errorMessage in
                emailValidationResultLabel.text = errorMessage
            }
            .store(in: &cancellables)
        
        viewModel.$passwordValidationError
            .receive(on: RunLoop.main)
            .sink { [unowned self] errorMessage in
                passwordValidationResultLabel.text = errorMessage
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func onTouchedSignUpButton(_ sender: UIButton) {
        viewModel.authenticate()
    }
    
    private func dismissAndNavigateOnboardWalkThrough() {
        let parent = parent
        view.removeFromSuperview()
        removeFromParent()
        didMove(toParent: parent)
        
        // TODO: show walk through
    }
}

extension SignUpViewController: UITextFieldDelegate {
    // became first responder
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function, textField.text ?? "")
    }
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(#function, textField.text ?? "")
    }
    
    @objc
    private func textFieldTextDidChangeNotification(_ sender: Notification) {
        guard let textField = sender.object as? UITextField else { return }
        if textField == emailTextField {
            viewModel.email = textField.text ?? ""
        } else if textField == passwordTextField {
            viewModel.password = textField.text ?? ""
        }
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
