// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SwiftMulticastDelegate",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(name: "SwiftMulticastDelegate", targets: ["SwiftMulticastDelegate"]),
    ],
    targets: [
        .target(
            name: "SwiftMulticastDelegate",
            path: "Source"
        ),
        .testTarget(
            name: "SwiftMulticastDelegateTests",
            dependencies: ["SwiftMulticastDelegate"],
            path: "Tests"
        )
    ]
)
