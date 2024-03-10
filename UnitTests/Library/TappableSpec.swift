//
//  TappableSpec.swift
//  UnitTests
//  
//  Created by mothule on 2024/02/04
//  
//

import Quick
import Nimble
import Combine
@testable import ios_app_sample


final class TappableSpec: QuickSpec {
    override class func spec() {
        describe("Tappable") {
            describe("extends AnyObject") {
                it("") {
                    expect(Class(name: "").tap { $0.name = "name" }.name) == "name"
                }
            }
            
            describe("struct") {
                it("") {
                    expect(Struct(name: "").tap { $0.name = "name" }.name) == "name"
                }
                it("") {
                    expect("".tap { $0 = "name" }) == "name"
                }
            }
            
            describe("URLComponents") {
                it("") {
                    var url = URL(string: "https://www.google.co.jp")!
                    var c = URLComponents().tap {
                        $0.queryItems = [.init(name: "test", value: "value")]
                    }
                    expect(c.url(relativeTo: url)?.absoluteString) == "https://www.google.co.jp?test=value"
                }

            }

        }
    }
}

private class Class: Tappable {
    var name: String
    init(name: String) {
        self.name = name
    }
}

private struct Struct: Tappable {
    var name: String
}
