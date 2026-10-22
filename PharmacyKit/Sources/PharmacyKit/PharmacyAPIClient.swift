import Foundation

public enum PharmacyAPIError: Error, Equatable, Sendable {
    case invalidResponse
    case server(statusCode: Int)
}

/// Calls the same `GET /api/pharmacies` endpoint the pharmacy-finder-web app
/// exposes, so both clients share one backend and one data pipeline.
public struct PharmacyAPIClient: Sendable {
    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchNearestPharmacies(lat: Double, lon: Double) async throws -> PharmacySearchResult {
        guard
            var components = URLComponents(
                url: baseURL.appendingPathComponent("api/pharmacies"),
                resolvingAgainstBaseURL: false
            )
        else {
            throw PharmacyAPIError.invalidResponse
        }

        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
        ]

        guard let url = components.url else {
            throw PharmacyAPIError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PharmacyAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PharmacyAPIError.server(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(PharmacySearchResult.self, from: data)
    }
}
