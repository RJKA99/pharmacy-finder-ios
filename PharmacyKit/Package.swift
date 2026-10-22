// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PharmacyKit",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "PharmacyKit", targets: ["PharmacyKit"])
    ],
    targets: [
        .target(name: "PharmacyKit"),
        .testTarget(name: "PharmacyKitTests", dependencies: ["PharmacyKit"]),
    ]
)
