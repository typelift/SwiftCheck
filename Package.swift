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
		.package(url: "https://github.com/trill-lang/FileCheck.git", from: "0.0.3")
	],
	targets: [
		.target(
			name: "SwiftCheck"),
		.testTarget(
			name: "SwiftCheckTests",
			dependencies: ["SwiftCheck", "FileCheck"]),
	]
)

