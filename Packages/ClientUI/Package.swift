// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClientUI",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "ServerUIClient", targets: ["ClientUI"])
    ],
    targets: [
        .target(name: "ClientUI", path: "Sources/ClientUI")
    ]
)
