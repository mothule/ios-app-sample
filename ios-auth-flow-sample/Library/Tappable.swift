//
//  Tappable.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/10/22.
//

import Foundation

protocol Tappable {}

extension Tappable {
    func tap(block: (inout Self) -> ()) -> Self {
        var tmp = self
        block(&tmp)
        return tmp
    }
}

extension NSObject: Tappable {}
extension JSONDecoder: Tappable {}
