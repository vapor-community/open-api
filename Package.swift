// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "open-api",
    products: [
        .library(name: "OpenAPI", targets: ["OpenAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .branch("master")),
        .package(url: "https://github.com/vapor/codable-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "OpenAPI", dependencies: ["Vapor", "CodableKit"]),
        .testTarget(name: "OpenAPITests", dependencies: ["OpenAPI"]),
    ]
)
