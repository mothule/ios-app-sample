//
//  SignUpViewController.swift
//  ios-auth-flow-sample
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
        
        $0.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor).isActive = true
        $0.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor).isActive = true
    }
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            $0.addArrangedSubview(UILabel().tap {
                $0.font = UIFont.boldSystemFont(ofSize: 24.0)
                $0.text = "SIGN UP"
                $0.translatesAutoresizingMaskIntoConstraints = false
            })
            $0.addArrangedSubview(.verticalSpacer(32))
            $0.addArrangedSubview(UILabel().tap {
                $0.text = "Email"
                $0.translatesAutoresizingMaskIntoConstraints = false
            })
            $0.addArrangedSubview(.verticalSpacer(4))
            $0.addArrangedSubview(emailTextField)
            $0.addArrangedSubview(emailValidationResultLabel)
            $0.addArrangedSubview(.verticalSpacer(8))
            $0.addArrangedSubview(UILabel().tap {
                $0.text = "Password"
                $0.translatesAutoresizingMaskIntoConstraints = false
            })
            $0.addArrangedSubview(.verticalSpacer(4))
            $0.addArrangedSubview(passwordTextField)
            $0.addArrangedSubview(passwordValidationResultLabel)
            $0.addArrangedSubview(.verticalSpacer(16))
            $0.addArrangedSubview(signUpButton)
        }
        self.view.addSubview(container)
        self.view.addSubview(modalIndicatorView)
        
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
            + NSLayoutConstraint.constraints(
                withVisualFormat: "|[indicator]|",
                metrics: nil,
                views: ["indicator": modalIndicatorView]
            )
            + NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[indicator]|",
                metrics: nil,
                views: ["indicator": modalIndicatorView]
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
        viewModel.output.$dialogError
            .compactMap { $0 }
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
            .assign(to: \.text, on: emailValidationResultLabel)
            .store(in: &cancellables)
        
        viewModel.output.$passwordValidationError
            .map { $0?.errorDescription }
            .assign(to: \.text, on: passwordValidationResultLabel)
            .store(in: &cancellables)
        viewModel.output.$dialogError
            .compactMap { $0 }
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
            .publisher(for: UITextField.textDidChangeNotification, object: emailTextField)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text })
            .replaceNil(with: "")
            .assign(to: &viewModel.input.$email)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
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

import SwiftUI
struct SignUpViewController_Preview: PreviewProvider {
    struct Wrapper: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            SignUpViewController.diContainer().resolve(SignUpViewController.self)
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
