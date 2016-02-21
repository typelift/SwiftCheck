import PackageDescription

let package = Package(
    name: "SwiftCheck",
    dependencies: [
        .Package(url: "https://github.com/typelift/Operadics.git", Version(0, 2, 0)),
    ]
)

