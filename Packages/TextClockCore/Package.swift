// swift-tools-version:5.9
import PackageDescription

// Package for the phrasing logic and the shared clock view, so both can be
// tested with `swift test` without building the app or widget.
let package = Package(
    name: "TextClockCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TextClockCore", targets: ["TextClockCore"]),
        .library(name: "TextClockUI", targets: ["TextClockUI"]),
    ],
    targets: [
        .target(name: "TextClockCore"),
        // The clock face drawn by both the app window and the widget.
        .target(name: "TextClockUI", dependencies: ["TextClockCore"]),
        .testTarget(name: "TextClockCoreTests", dependencies: ["TextClockCore"]),
        .testTarget(name: "TextClockUITests", dependencies: ["TextClockUI"]),
    ]
)
