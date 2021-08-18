// swift-tools-version:5.2

import PackageDescription

let package = Package(
        name: "SwiftCheck",
        products: [
            .library(
                    name: "SwiftCheck",
                    targets: ["SwiftCheck"]),
        ],
        dependencies: [
            .package(url: "https://github.com/llvm-swift/FileCheck.git", from: "0.1.0"),
        ],
        targets: [
            .target(
                    name: "SwiftCheck"),
            .testTarget(
                    name: "SwiftCheckTests",
                    dependencies: ["SwiftCheck", "FileCheck", ],
                    linkerSettings: [
                        .unsafeFlags(["-Xlinker", "-rpath",
                                      "-Xlinker", "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib"],
                                .when(platforms: [.macOS])
                        ),
                    ]),
        ]
)

