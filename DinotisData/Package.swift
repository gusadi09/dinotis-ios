// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DinotisData",
	defaultLocalization: "id",
	platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DinotisData",
            targets: ["DinotisData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		.package(url: "https://github.com/jrendel/SwiftKeychainWrapper.git", .upToNextMinor(from: "4.0.0")),
		.package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
		.package(url: "https://github.com/marinofelipe/CurrencyText.git", .upToNextMinor(from: .init(2, 2, 0))),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DinotisData",
            dependencies: [
				.byName(name: "Moya"),
				.byName(name: "SwiftKeychainWrapper"),
				.product(name: "CurrencyFormatter", package: "CurrencyText"),
			],
			resources: [
				.process("./Localization/String")
			]
		),
        .testTarget(
            name: "DinotisDataTests",
            dependencies: ["DinotisData"]),
    ]
)
