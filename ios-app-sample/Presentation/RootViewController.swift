//
//  RootViewController.swift
//  ios-app-sample
//
//  Created by mothule on 2023/09/08.
//

import UIKit
import Combine

class RootViewController: UIViewController {
    private var viewModel: RootViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        var view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = .white
        self.view.addSubview(indicatorView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.validUserIdentifier()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.addConstraints({() -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[indicator]-|",
                metrics: nil,
                views: ["indicator": indicatorView]
            ) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[indicator]-|",
                metrics: nil,
                views: ["indicator": indicatorView]
            )
        }())
    }
    
    private func setupBindings() {
        viewModel.$procState
            .compactMap{$0} // ignore nil
            .receive(on: RunLoop.main)
            .sink { [unowned self] viewState in
                switch viewState {
                case .entry:
                    indicatorView.startAnimating()
                    
                case .signIn:
                    indicatorView.stopAnimating()
                    showSignIn()
                    
                case .signUp:
                    indicatorView.stopAnimating()
                    showSignUp()
                    
                case .main:
                    indicatorView.stopAnimating()
                    showMain()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showSignIn() {
        print(#function)
    }
    
    private func showSignUp() {
        let vc: SignUpViewController = .diContainer().resolve()
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    private func showMain() {
        print(#function)
    }
}
