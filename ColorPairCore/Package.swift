// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ColorPairCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ColorPairCore", targets: ["ColorPairCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing", from: "0.9.0")
    ],
    targets: [
        .target(name: "ColorPairCore"),
        .testTarget(
            name: "ColorPairCoreTests",
            dependencies: [
                "ColorPairCore",
                .product(name: "Testing", package: "swift-testing")
            ],
            swiftSettings: [
                // Only affects this test target; app code still shows real warnings.
                .unsafeFlags(["-suppress-warnings"])
            ]
        ),
    ]
)
