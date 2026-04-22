// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MapScaleView",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MapScaleView", targets: ["MapScaleView"]),
    ],
    targets: [
        .target(
            name: "MapScaleView",
            path: "Sources/MapScaleView"
        ),
        .testTarget(
            name: "MapScaleViewTests",
            dependencies: ["MapScaleView"],
            path: "Tests/MapScaleViewTests"
        ),
    ]
)
