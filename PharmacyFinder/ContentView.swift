import CoreLocation
import PharmacyKit
import SwiftUI

private let apiBaseURL = URL(string: "https://pharmacy-finder-web.vercel.app")!

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = PharmacyListViewModel(
        client: PharmacyAPIClient(baseURL: apiBaseURL)
    )
    @State private var locationErrorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Find the nearest pharmacies using your current location.")
                    .foregroundStyle(.secondary)

                Button(action: search) {
                    if isBusy {
                        ProgressView()
                    } else {
                        Text("Find nearest pharmacy")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)

                if let locationErrorMessage {
                    Text(locationErrorMessage)
                        .foregroundStyle(.red)
                }

                resultsView
            }
            .padding()
            .navigationTitle("Pharmacy Finder")
        }
    }

    private var isBusy: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    @ViewBuilder
    private var resultsView: some View {
        switch viewModel.state {
        case .idle, .loading:
            EmptyView()
        case .empty:
            Text("No pharmacies found nearby. Try again from a different location.")
                .foregroundStyle(.secondary)
        case .failed(let message):
            Text(message)
                .foregroundStyle(.red)
        case .loaded(let result):
            List(result.pharmacies) { pharmacy in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pharmacy.name).font(.headline)
                        if let address = pharmacy.address {
                            Text(address).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(DistanceFormatting.format(meters: pharmacy.distanceMeters))
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
            }
            .listStyle(.plain)
        }
    }

    private func search() {
        locationErrorMessage = nil
        Task {
            do {
                let coordinate = try await locationManager.requestLocation()
                await viewModel.search(lat: coordinate.latitude, lon: coordinate.longitude)
            } catch let error as CLError where error.code == .denied {
                locationErrorMessage = "Location permission was denied. Allow location access in Settings and try again."
            } catch {
                locationErrorMessage = "We couldn't determine your location. Please try again."
            }
        }
    }
}

#Preview {
    ContentView()
}
