// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ServerApp",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ServerApp", targets: ["ServerApp"])
    ],
    dependencies: [
        // local dependency on your server-side package
        .package(path: "../../Packages/ServerUI"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "ServerApp",
            dependencies: [
                .product(name: "ServerUI", package: "ServerUI"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/ServerApp",
            linkerSettings: [
                .linkedFramework("Network")
            ]
        )
    ]
)
