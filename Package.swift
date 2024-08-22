// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "IdentifiableContinuation",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "IdentifiableContinuation",
            targets: ["IdentifiableContinuation"]
        )
    ],
    targets: [
        .target(
            name: "IdentifiableContinuation",
            path: "Sources",
            swiftSettings: .upcomingFeatures
        ),
        .testTarget(
            name: "IdentifiableContinuationTests",
            dependencies: ["IdentifiableContinuation"],
            path: "Tests",
            swiftSettings: .upcomingFeatures
        )
    ]
)

extension Array where Element == SwiftSetting {

    static var upcomingFeatures: [SwiftSetting] {
        [
            .enableUpcomingFeature("ExistentialAny"),
            .swiftLanguageMode(.v5)
        ]
    }
}
