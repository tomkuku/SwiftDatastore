// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "SwiftDatastore",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftDatastore",
            targets: ["SwiftDatastore"]
        )
    ],
    targets: [
        .target(
            name: "SwiftDatastore",
            path: "SwiftDatastore/SwiftDatastore",
            sources: ["SwiftDatastore/SwiftDatastore"]
        )
    ]
)
