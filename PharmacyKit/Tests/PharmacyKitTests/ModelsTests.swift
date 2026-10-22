import XCTest
@testable import PharmacyKit

final class ModelsTests: XCTestCase {
    func testDecodesAFullPharmacySearchResult() throws {
        let json = """
        {
            "pharmacies": [
                {
                    "id": "overture:1",
                    "name": "Yliopiston Apteekki",
                    "lat": 60.1699,
                    "lon": 24.9384,
                    "address": "Mannerheimintie 5, 00100, Helsinki",
                    "source": "overture",
                    "distanceMeters": 78
                }
            ],
            "searchRadiusMeters": 1500,
            "generatedAt": "2026-01-01T00:00:00.000Z"
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(PharmacySearchResult.self, from: json)

        XCTAssertEqual(result.pharmacies.count, 1)
        XCTAssertEqual(result.pharmacies[0].name, "Yliopiston Apteekki")
        XCTAssertEqual(result.pharmacies[0].distanceMeters, 78)
        XCTAssertEqual(result.searchRadiusMeters, 1500)
    }

    func testDecodesAMissingAddressAsNil() throws {
        let json = """
        {
            "pharmacies": [
                {
                    "id": "overture:2",
                    "name": "Apteekki",
                    "lat": 60.1,
                    "lon": 24.9,
                    "address": null,
                    "source": "overture",
                    "distanceMeters": 200
                }
            ],
            "searchRadiusMeters": 1500,
            "generatedAt": "2026-01-01T00:00:00.000Z"
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(PharmacySearchResult.self, from: json)
        XCTAssertNil(result.pharmacies[0].address)
    }

    func testDecodesAnEmptyPharmacyList() throws {
        let json = """
        { "pharmacies": [], "searchRadiusMeters": 20000, "generatedAt": "2026-01-01T00:00:00.000Z" }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(PharmacySearchResult.self, from: json)
        XCTAssertTrue(result.pharmacies.isEmpty)
    }
}
