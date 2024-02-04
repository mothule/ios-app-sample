//
//  DecodingStrategy.swift
//  ios-auth-flow-sample
//  
//  Created by mothule on 2024/02/05
//  
//

import Foundation

protocol DecodingStrategy {
    associatedtype DecodedType
    var acceptMimeType: String { get }
    func decode(data: Data) throws -> DecodedType
}

struct JsonDecoder<T: Decodable>: DecodingStrategy {
    typealias DecodedType = T
    var acceptMimeType: String { "application/json" }
    
    func decode(data: Data) throws -> DecodedType {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            switch error {
            case let .keyNotFound(key, context):
                let contextDebugDesc: [String] = [
                    context.codingPath.map(\.stringValue).joined(separator: ","),
                    context.debugDescription,
                    context.underlyingError?.localizedDescription ?? ""
                ]
                print("Key not found.", key.stringValue, contextDebugDesc)
            case let .valueNotFound(type, context):
                let contextDebugDesc: [String] = [
                    context.codingPath.map(\.stringValue).joined(separator: ","),
                    context.debugDescription,
                    context.underlyingError?.localizedDescription ?? ""
                ]
                print("Value not found.", String(describing: type), contextDebugDesc)
            case let .typeMismatch(type, context):
                let contextDebugDesc: [String] = [
                    context.codingPath.map(\.stringValue).joined(separator: ","),
                    context.debugDescription,
                    context.underlyingError?.localizedDescription ?? ""
                ]
                print("Type mismatch.", String(describing: type), contextDebugDesc)
            case let .dataCorrupted(context):
                let contextDebugDesc: [String] = [
                    context.codingPath.map(\.stringValue).joined(separator: ","),
                    context.debugDescription,
                    context.underlyingError?.localizedDescription ?? ""
                ]
                print("Data corrupted.", contextDebugDesc)
            @unknown default:
                fatalError()
            }
            throw ApiError.responseError
        }
    }
}
struct StringDecoder: DecodingStrategy {
    typealias DecodedType = String
    var acceptMimeType: String { "text/plain" }
    let encoding: String.Encoding
    
    func decode(data: Data) throws -> String {
        guard let string = String(data: data, encoding: encoding) else { throw ApiError.responseError }
        return string
    }
}
