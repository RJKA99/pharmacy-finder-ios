import Foundation

public enum DistanceFormatting {
    /// Formats a distance in meters the way a user expects to read it: "350 m" or "1.2 km".
    public static func format(meters: Int) -> String {
        if meters < 1000 {
            return "\(meters) m"
        }
        let kilometers = Double(meters) / 1000
        return String(format: "%.1f km", kilometers)
    }
}
