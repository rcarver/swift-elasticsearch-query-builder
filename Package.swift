// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-elasticsearch-query-builder",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ElasticsearchQueryBuilder",
            targets: ["ElasticsearchQueryBuilder"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "ElasticsearchQueryBuilder",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ElasticsearchQueryBuilderTests",
            dependencies: [
                "ElasticsearchQueryBuilder",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
