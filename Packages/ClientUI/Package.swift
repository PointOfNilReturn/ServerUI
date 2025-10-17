// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClientUI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ServerUIClient", targets: ["ClientUI"])
    ],
    dependencies: [
        .package(path: "../ViewSchema")
    ],
    targets: [
        .target(
            name: "ClientUI",
            dependencies: ["ViewSchema"],
            path: "Sources/ClientUI"
        )
    ]
)
