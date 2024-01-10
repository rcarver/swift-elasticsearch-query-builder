// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-elasticsearch-query-builder",
    products: [
        .library(
            name: "ElasticSearchQueryBuilder",
            targets: ["ElasticSearchQueryBuilder"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "ElasticSearchQueryBuilder"
        ),
        .testTarget(
            name: "ElasticSearchQueryBuilderTests",
            dependencies: [
                "ElasticSearchQueryBuilder",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
