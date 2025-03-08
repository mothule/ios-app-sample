//
//  TextForm.swift
//  ios-app-sample
//
//  Created by mothule on 2025/03/08.
//

import UIKit


class TextForm: UIView {
    
    var titleLabel: UILabel = .init().tap {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    var textField: UITextField = .init().tap {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.borderStyle = .roundedRect
    }
    var validationResultLabel: UILabel = .init().tap {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .right
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 12)
    }
    
    init(title: String, initialText: String? = nil) {
        super.init(frame: .zero)
        setupViewAndSubviews()
        titleLabel.text = title
        textField.text = initialText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewAndSubviews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    private func setupViewAndSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
//        backgroundColor = .blue
//        titleLabel.backgroundColor = .yellow
        
        // add subviews
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(validationResultLabel)
        
        [
            // title layout
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -4),
            
            // textField layout
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: validationResultLabel.topAnchor),

            // validation result layout
            validationResultLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            validationResultLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            validationResultLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ].forEach { $0.isActive = true }
    }
}

#Preview {
    return TextForm(title: "Email", initialText: "email@domain.co.jp").tap {
        $0.validationResultLabel.text = "hogehogehoge"
    }
}
