// swift-tools-version:5.9
import PackageDescription

// Package for the platform-independent phrasing logic, so it can be tested
// with `swift test` without building the app or widget.
let package = Package(
    name: "TextClockCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TextClockCore", targets: ["TextClockCore"]),
    ],
    targets: [
        .target(name: "TextClockCore"),
        .testTarget(name: "TextClockCoreTests", dependencies: ["TextClockCore"]),
    ]
)
