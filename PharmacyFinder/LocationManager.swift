import CoreLocation

/// Thin async wrapper around CLLocationManager's delegate API.
@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    /// Requests permission (if needed) and resolves with the user's current
    /// coordinate. Throws a CLError (e.g. `.denied`) if permission is
    /// refused or the location can't be determined.
    func requestLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.first else { return }
            continuation?.resume(returning: location.coordinate)
            continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
}
