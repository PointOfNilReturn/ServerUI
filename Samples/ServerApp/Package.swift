// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ServerApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ServerApp", targets: ["ServerApp"])
    ],
    dependencies: [
        // local dependency on your server-side package
        .package(path: "../../Packages/ServerUI")
    ],
    targets: [
        .executableTarget(
            name: "ServerApp",
            dependencies: [
                .product(name: "ServerUI", package: "ServerUI")
            ],
            path: "Sources/ServerApp",
            linkerSettings: [
                .linkedFramework("Network")
            ]
        )
    ]
)
