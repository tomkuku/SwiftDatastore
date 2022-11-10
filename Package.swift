// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "SwiftDatastore",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/tomkuku/SwiftDatastore.git", 
        from: "0.2.2")
    ],
    targets: [
        .target(
            name: "SwiftDatastore")
    ]
)
