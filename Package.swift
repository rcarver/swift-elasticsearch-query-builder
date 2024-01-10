// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-elasticsearch-query",
    products: [
        .library(
            name: "ElasticSearchQuery",
            targets: ["ElasticSearchQuery"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "ElasticSearchQuery"
        ),
        .testTarget(
            name: "ElasticSearchQueryTests",
            dependencies: [
                "ElasticSearchQuery",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
