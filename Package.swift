// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "open-api",
    products: [
        .library(name: "OpenAPI", targets: ["OpenAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .branch("master")),
    ],
    targets: [
        .target(name: "OpenAPI", dependencies: ["Vapor"]),
        .testTarget(name: "OpenAPITests", dependencies: ["OpenAPI"]),
    ]
)
