// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "SwiftCheck",
	products: [
		.library(
			name: "SwiftCheck",
			targets: ["SwiftCheck"]),
	],
	dependencies: [
		.package(url: "https://github.com/llvm-swift/FileCheck.git", from: "0.1.0")
	],
	targets: [
		.target(
			name: "SwiftCheck"),
		.testTarget(
			name: "SwiftCheckTests",
			dependencies: ["SwiftCheck", "FileCheck"]),
	]
)

