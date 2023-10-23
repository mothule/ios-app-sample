//
//  DefaultsKeys.swift
//  ios-auth-flow-sample
//
//  Created by mothule on 2023/09/08.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let apiAccessToken = Key<String>("api_access_token", default: "")
}
