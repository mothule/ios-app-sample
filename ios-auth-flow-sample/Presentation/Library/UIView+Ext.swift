//
//  UIView+Ext.swift
//  ios-auth-flow-sample
//
//  Created by Motoki Kawakami on 2023/10/22.
//

import Foundation
import UIKit

extension UIView {
    static var spacer: UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
    static func verticalSpacer(_ val: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[self(\(val))]",
                metrics: nil,
                views: ["self": v]
            )
        )
        return v
    }
}

extension UILabel {
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

