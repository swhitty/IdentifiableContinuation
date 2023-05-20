// swift-tools-version:5.7

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
            path: "Sources"
        ),
        .testTarget(
            name: "IdentifiableContinuationTests",
            dependencies: ["IdentifiableContinuation"],
            path: "Tests"
        )
    ]
)
