import Foundation

/// Mirrors the JSON shape returned by the web app's `GET /api/pharmacies`
/// endpoint (see pharmacy-finder-web's `src/lib/types.ts`).
public struct Pharmacy: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let lat: Double
    public let lon: Double
    public let address: String?
    public let source: String
    public let distanceMeters: Int

    public init(
        id: String,
        name: String,
        lat: Double,
        lon: Double,
        address: String?,
        source: String,
        distanceMeters: Int
    ) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.address = address
        self.source = source
        self.distanceMeters = distanceMeters
    }
}

public struct PharmacySearchResult: Codable, Equatable, Sendable {
    public let pharmacies: [Pharmacy]
    public let searchRadiusMeters: Int
    public let generatedAt: String

    public init(pharmacies: [Pharmacy], searchRadiusMeters: Int, generatedAt: String) {
        self.pharmacies = pharmacies
        self.searchRadiusMeters = searchRadiusMeters
        self.generatedAt = generatedAt
    }
}
