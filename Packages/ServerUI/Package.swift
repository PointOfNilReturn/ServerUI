// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ServerUI",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ServerUI", targets: ["ServerUI"])
    ],
    dependencies: [
        .package(path: "../ViewSchema"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0")
    ],
    targets: [
        // Macro implementation
        .macro(
            name: "ServerUIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        // Main library
        .target(
            name: "ServerUI",
            dependencies: [
                "ViewSchema",
                "ServerUIMacros"
            ],
            path: "Sources/ServerUI"
        ),
        
        // Tests for macros
        .testTarget(
            name: "ServerUIMacroTests",
            dependencies: [
                "ServerUIMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        
        // Tests for ServerUI
        .testTarget(
            name: "ServerUITests",
            dependencies: ["ServerUI", "ViewSchema"]
        )
    ]
)
