//
//  DomainError.swift
//  ios-app-sample
//  
//  Created by mothule on 2024/01/21
//  
//

import Foundation

/// ドメイン内の全エラーを列挙
enum DomainErrorCode: Int {
    case invalidApiAccessToken
    case unknown = 99999999
}

protocol AppErrorble: LocalizedError & CustomNSError {}

struct DomainError: AppErrorble {
    var code: DomainErrorCode
    var errorDescription: String?
    var internalError: Error?
}

/// Error一覧
extension DomainError {
    static func fromRepositoryError(_ repositoryError: RepositoryError) -> Self {
        switch repositoryError {
        case .emptyApiAccessToken: 
            return .init(code: .invalidApiAccessToken, errorDescription: "APIアクセストークンが空です", internalError: repositoryError)
        case .invalidApiAccessToken:
            return .init(code: .invalidApiAccessToken, errorDescription: "無効なアクセストークンです", internalError: repositoryError)
        }
    }
    
    static func unknown(error: Error?) -> Self {
        .init(code: .unknown, errorDescription: "不明なエラーが発生しました", internalError: error)
    }
}

