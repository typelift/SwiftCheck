// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "SwiftCheck",
	products: [
        .library(
            name: "SwiftCheck",
            targets: ["SwiftCheck"]),
    ],
    dependencies: [
		.package(url: "https://github.com/typelift/Operadics.git", .branch("swift-develop"))
	],
	targets: [
		.target(
            name: "SwiftCheck",
            dependencies: ["Operadics"]),
        .testTarget(
            name: "SwiftCheckTests",
            dependencies: ["SwiftCheck"]),
	]
)

