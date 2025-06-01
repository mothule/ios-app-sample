//
//  SignUpViewController.swift
//  ios-app-sample
//
//  Created by mothule on 2023/09/08.
//

import UIKit
import Combine
import CombineCocoa
import DIContainer

class SignUpViewController: UIViewController {
    private let viewModel: SignUpViewModel
    private var cancellables: Set<AnyCancellable> = []
    private lazy var signUpButton: UIButton = .init().tap {
        $0.setTitle("SIGN UP", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var emailForm: TextForm = .init().tap {
        $0.titleLabel.text = "Email"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textField.placeholder = "xxx@xxx.xxx"
        $0.textField.textContentType = .emailAddress
        $0.textField.autocorrectionType = .no
        $0.textField.autocapitalizationType = .none
    }
    private lazy var passwordForm: TextForm = .init().tap {
        $0.titleLabel.text = "Password"
        $0.textField.placeholder = "8 ~ "
        $0.textField.textContentType = .newPassword
        $0.textField.passwordRules = .init(descriptor: "minlength: 8; required: lower; required: upper; required: digit; required: [-];")
        $0.textField.isSecureTextEntry = true
    }
    
    // TODO: Modal Indicator View Componentとして抽出を検討する
    private lazy var modalIndicatorView: UIView = .init().tap {
        $0.backgroundColor = .init(white: 0.0, alpha: 0.5)
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large).tap {
            $0.color = .white
            $0.startAnimating()
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        $0.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            $0.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
            $0.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor),
        ])
    }
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds).tap {
            $0.backgroundColor = .systemBackground
        }
        
        let container: UIStackView = UIStackView().tap {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
            $0.layer.cornerRadius = 8.0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addArrangedSubview(UILabel().tap {
                $0.font = UIFont.boldSystemFont(ofSize: 24.0)
                $0.text = "SIGN UP"
                $0.translatesAutoresizingMaskIntoConstraints = false
            })
            $0.addArrangedSubview(.verticalSpacer(32))
            $0.addArrangedSubview(emailForm)
            $0.addArrangedSubview(.verticalSpacer(8))
            $0.addArrangedSubview(passwordForm)
            $0.addArrangedSubview(.verticalSpacer(16))
            $0.addArrangedSubview(signUpButton)
        }
        self.view.addSubview(container)
        self.view.addSubview(modalIndicatorView)

        NSLayoutConstraint.activate([
            // Container layout
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Email form layout
            // Y軸は親ViewがUIStack.verticalなので設定不要
            emailForm.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emailForm.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            // Password form layout
            // Y軸は親ViewがUIStack.verticalなので設定不要
            passwordForm.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            passwordForm.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            // Sign up Button laout
            // Y軸は親ViewがUIStack.verticalなので設定不要
            signUpButton.heightAnchor.constraint(equalToConstant: 44),
            signUpButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            // Modal Indicator layout
            modalIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: Self.self), #function)
        setBindings()
    }
    
    private func setBindings() {
        viewModel.output.$dialogError
            .ignoreNil()
            .sink { [unowned self] error in
                let alert = UIAlertController(
                    title: "ERROR",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "OK", style: .default))
                present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.routePublisher
            .sink { [unowned self] route in
                switch route {
                case .navigateOnboardingWalkThrough:
                    dismissAndNavigateOnboardWalkThrough()
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.$isShownProgress
            .receive(on: RunLoop.main)
            .sink { [unowned self] isShownProgress in
                modalIndicatorView.isHidden = !isShownProgress
            }
            .store(in: &cancellables)
        
        viewModel.output.$isEnabledSignUp
            .receive(on: RunLoop.main)
            .sink { [unowned self] isEnabled in
                signUpButton.isEnabled = isEnabled
                UIView.animate(withDuration: 0.3) {
                    self.signUpButton.backgroundColor = isEnabled ? .magenta : .gray
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.$emailValidationError
            .map { $0?.errorDescription }
            .assign(to: \.text, on: emailForm.validationResultLabel)
            .store(in: &cancellables)
        
        viewModel.output.$passwordValidationError
            .map { $0?.errorDescription }
            .assign(to: \.text, on: passwordForm.validationResultLabel)
            .store(in: &cancellables)
        viewModel.output.$dialogError
            .ignoreNil()
            .sink { [unowned self] signUpViewError in
                let alert = UIAlertController(
                    title: "ERROR",
                    message: signUpViewError.errorDescription,
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "OK", style: .destructive))
                present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        
        // Bindings View → ViewModel
        signUpButton.tapPublisher.sink { [unowned self] _ in
            viewModel.input.authenticateSubject.send()
        }
        .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailForm.textField)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text })
            .replaceNil(with: "")
            .assign(to: &viewModel.input.$email)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordForm.textField)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text })
            .replaceNil(with: "")
            .assign(to: &viewModel.input.$password)
        
    }
    
    private func dismissAndNavigateOnboardWalkThrough() {
        let parent = parent
        view.removeFromSuperview()
        removeFromParent()
        didMove(toParent: parent)
        
        // TODO: show walk through
    }
}

extension SignUpViewController: DIContainerInjectable {
    static func diContainer() -> DIContainer.Container {
        Container.shared.merging(
            .init().register(SignUpViewController.self) { c in SignUpViewController(viewModel: c.resolve()) }
                .register(SignUpViewModel.self) { c in SignUpViewModel(userAuthenticationUsecase: c.resolve()) }
        )
    }
}

#Preview {
    let vc = SignUpViewController.diContainer().resolve(SignUpViewController.self)
    return vc
    
}
