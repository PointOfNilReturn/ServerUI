// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ServerUI",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ServerUI", targets: ["ServerUI"])
    ],
    dependencies: [
        .package(path: "../ViewSchema")
    ],
    targets: [
        .target(
            name: "ServerUI",
            dependencies: ["ViewSchema"],
            path: "Sources/ServerUI"
        )
    ]
)
