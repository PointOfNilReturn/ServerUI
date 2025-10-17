// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClientUI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ServerUIClient", targets: ["ClientUI"])
    ],
    dependencies: [
        .package(path: "../ViewSchema"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "ClientUI",
            dependencies: [
                "ViewSchema",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/ClientUI"
        )
    ]
)
