import Foundation

public enum PharmacyLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded(PharmacySearchResult)
    case empty
    case failed(String)
}

@MainActor
public final class PharmacyListViewModel: ObservableObject {
    @Published public private(set) var state: PharmacyLoadState = .idle

    private let client: PharmacyAPIClient

    public init(client: PharmacyAPIClient) {
        self.client = client
    }

    public func search(lat: Double, lon: Double) async {
        state = .loading
        do {
            let result = try await client.fetchNearestPharmacies(lat: lat, lon: lon)
            state = result.pharmacies.isEmpty ? .empty : .loaded(result)
        } catch {
            state = .failed(Self.message(for: error))
        }
    }

    static func message(for error: Error) -> String {
        if let apiError = error as? PharmacyAPIError {
            switch apiError {
            case .invalidResponse:
                return "Received an unexpected response from the server."
            case .server(let statusCode):
                return "Server error (\(statusCode)). Please try again shortly."
            }
        }
        return "Couldn't reach the pharmacy lookup service. Please try again shortly."
    }
}
