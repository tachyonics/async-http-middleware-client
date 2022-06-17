// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "async-http-middleware-client",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AsyncHttpMiddlewareClient",
            targets: ["AsyncHttpMiddlewareClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.4"),
        .package(url: "https://github.com/tachyonics/swift-http-client-middleware", branch: "poc")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AsyncHttpMiddlewareClient", dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "HttpClientMiddleware", package: "swift-http-client-middleware"),
            ]),
        .testTarget(
            name: "AsyncHttpMiddlewareClientTests", dependencies: [
                .target(name: "AsyncHttpMiddlewareClient"),
            ]),
    ]
)
