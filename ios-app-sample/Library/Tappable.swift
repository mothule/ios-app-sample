//
//  Tappable.swift
//  ios-app-sample
//
//  Created by mothule on 2023/10/22.
//

import Foundation

protocol Tappable {}

/// Object#tap of ActiveSupport like.
/// ```
/// var url = URL(string: "https://www.google.co.jp")!
/// var c = URLComponents().tap {
///     $0.queryItems = [.init(name: "test", value: "value")]
/// }
/// ```
extension Tappable {
    func tap(block: (inout Self) -> ()) -> Self {
        var tmp = self
        block(&tmp)
        return tmp
    }
}

extension NSObject: Tappable {}
extension JSONDecoder: Tappable {}
