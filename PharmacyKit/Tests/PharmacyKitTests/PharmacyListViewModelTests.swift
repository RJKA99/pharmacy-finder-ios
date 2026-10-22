import XCTest
@testable import PharmacyKit

@MainActor
final class PharmacyListViewModelTests: XCTestCase {
    private func makeViewModel(statusCode: Int, body: Data) -> PharmacyListViewModel {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        let client = PharmacyAPIClient(baseURL: URL(string: "https://example.com")!, session: MockURLProtocol.makeSession())
        return PharmacyListViewModel(client: client)
    }

    func testTransitionsToLoadedOnSuccessWithResults() async {
        let json = """
        {
            "pharmacies": [
                {"id":"1","name":"A","lat":60.1,"lon":24.9,"address":null,"source":"overture","distanceMeters":100}
            ],
            "searchRadiusMeters": 1500,
            "generatedAt": "2026-01-01T00:00:00.000Z"
        }
        """.data(using: .utf8)!

        let viewModel = makeViewModel(statusCode: 200, body: json)
        XCTAssertEqual(viewModel.state, .idle)

        await viewModel.search(lat: 60.1, lon: 24.9)

        guard case .loaded(let result) = viewModel.state else {
            return XCTFail("expected .loaded, got \(viewModel.state)")
        }
        XCTAssertEqual(result.pharmacies.count, 1)
    }

    func testTransitionsToEmptyWhenResultHasNoPharmacies() async {
        let json = """
        { "pharmacies": [], "searchRadiusMeters": 20000, "generatedAt": "2026-01-01T00:00:00.000Z" }
        """.data(using: .utf8)!

        let viewModel = makeViewModel(statusCode: 200, body: json)
        await viewModel.search(lat: 69.0, lon: 27.0)

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testTransitionsToFailedOnServerError() async {
        let viewModel = makeViewModel(statusCode: 503, body: Data())
        await viewModel.search(lat: 60.1, lon: 24.9)

        guard case .failed(let message) = viewModel.state else {
            return XCTFail("expected .failed, got \(viewModel.state)")
        }
        XCTAssertTrue(message.contains("503"))
    }
}
