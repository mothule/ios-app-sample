//
//  IgnoreNil.swift
//  ios-app-sample
//  
//  Created by mothule on 2024/11/20
//  
//

import Foundation
import Combine

// ref: https://rizumita.medium.com/implementing-ignorenil-method-inside-publisher-of-combine-1622a8453b

protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}
extension Optional: OptionalType {
    var optional: Wrapped? { self }
}

extension Publisher where Output: OptionalType {
    func ignoreNil() -> AnyPublisher<Output.Wrapped, Failure> {
        flatMap {output -> AnyPublisher<Output.Wrapped, Failure> in
            guard let output = output.optional else {
                return Empty<Output.Wrapped, Failure>(completeImmediately: false).eraseToAnyPublisher()
            }
            return Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
