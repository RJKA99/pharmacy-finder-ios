import XCTest
@testable import PharmacyKit

final class PharmacyAPIClientTests: XCTestCase {
    func testParsesASuccessfulResponse() async throws {
        let json = """
        { "pharmacies": [], "searchRadiusMeters": 1500, "generatedAt": "2026-01-01T00:00:00.000Z" }
        """.data(using: .utf8)!

        MockURLProtocol.handler = { request in
            XCTAssertTrue(request.url!.absoluteString.contains("api/pharmacies"))
            XCTAssertTrue(request.url!.absoluteString.contains("lat=60.17"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let client = PharmacyAPIClient(baseURL: URL(string: "https://example.com")!, session: MockURLProtocol.makeSession())
        let result = try await client.fetchNearestPharmacies(lat: 60.17, lon: 24.94)

        XCTAssertEqual(result.searchRadiusMeters, 1500)
    }

    func testThrowsServerErrorForNon2xxResponses() async {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let client = PharmacyAPIClient(baseURL: URL(string: "https://example.com")!, session: MockURLProtocol.makeSession())

        do {
            _ = try await client.fetchNearestPharmacies(lat: 60.17, lon: 24.94)
            XCTFail("expected an error to be thrown")
        } catch PharmacyAPIError.server(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testThrowsOnMalformedJSON() async {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "not json".data(using: .utf8)!)
        }

        let client = PharmacyAPIClient(baseURL: URL(string: "https://example.com")!, session: MockURLProtocol.makeSession())

        do {
            _ = try await client.fetchNearestPharmacies(lat: 60.17, lon: 24.94)
            XCTFail("expected an error to be thrown")
        } catch {
            // any decoding error is acceptable here
        }
    }
}
