import XCTest
@testable import PharmacyKit

final class DistanceFormattingTests: XCTestCase {
    func testFormatsSubKilometerDistancesInMeters() {
        XCTAssertEqual(DistanceFormatting.format(meters: 350), "350 m")
        XCTAssertEqual(DistanceFormatting.format(meters: 0), "0 m")
    }

    func testFormatsOneKilometerAndAboveInKilometers() {
        XCTAssertEqual(DistanceFormatting.format(meters: 1200), "1.2 km")
        XCTAssertEqual(DistanceFormatting.format(meters: 1000), "1.0 km")
    }
}
