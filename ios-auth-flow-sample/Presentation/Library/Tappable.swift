//
//  Tappable.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/10/22.
//

import Foundation

protocol Tappable: AnyObject {}

extension Tappable where Self: NSObject {
    func tap(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Tappable {}
