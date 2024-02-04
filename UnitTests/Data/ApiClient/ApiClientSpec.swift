//
//  ApiClientSpec.swift
//  UnitTests
//  
//  Created by mothule on 2024/02/03
//  
//

import Quick
import Nimble
import Combine
@testable import ios_auth_flow_sample

final class ApiClientSpec: AsyncSpec {

    override class func spec() {
        describe("ApiClientImpl") {
            var target: ApiClientImpl!
            
            describe("sendHttpRequest(_:) -> Response") {
                beforeEach {
                    target = .init(session: .init(configuration: .default), configuration: .default)
                }
                
                it("") {
                    await expect {
                        let request = HogeRequest(latitude: "35.6785", longitude: "139.6823", timezone: "Asia/Tokyo", hourly: "temperature_2m")
                        return try await target.sendHttpRequest(request)
                    }.toNot(throwAssertion())
                }
            }
        }
    }
}

protocol TestRequestable: HttpRequestable {
    var path: String { get }
    var additionalHeaderFields: [String: String]? { get }
}
extension TestRequestable {
    var overwriteCachePolicy: URLRequest.CachePolicy? { nil }
    var overwriteRequestTimeoutInterval: TimeInterval? { nil }
    var httpHeaderFields: [String : String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ].merging(additionalHeaderFields ?? [:], uniquingKeysWith: { old, new in new })
    }
    var additionalHeaderFields: [String: String]? { nil }
    
    var baseURLString: String { "https://api.open-meteo.com/v1/" }
    var url: URL? {
        URLComponents(string: baseURLString)?.tap { $0.path = path }.url
    }
    
    func decodeResponseBody(data: Data) throws -> Response {
        try JsonDecoder().decode(data: data)
    }
}

private struct HogeRequest: TestRequestable {
    
    struct HogeResponse: HttpResponsable {
        var latitude: Double
        var longitude: Double
    }
    typealias Response = HogeResponse
    
    var httpMethod: HttpMethod { .get }
    var path: String { "/forecast" }
    
    // tokyo: latitude=35.6785&longitude=139.6823
    let latitude: String
    let longitude: String
    let timezone: String
    let hourly: String
    
    var queryParameters: [String : String?]? {
        [
            "latitude": latitude, "longitude": longitude,
            "timezone": timezone, "hourly": hourly,
        ]
    }
}
