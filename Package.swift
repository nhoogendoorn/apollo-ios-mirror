// swift-tools-version:5.9
//
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift 5.9 is available from Xcode 15.0.


import PackageDescription

let package = Package(
  name: "Apollo_Legacy",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "Apollo_Legacy", targets: ["Apollo_Legacy"]),
    .library(name: "ApolloAPI_Legacy", targets: ["ApolloAPI_Legacy"]),
    .library(name: "Apollo-Dynamic_Legacy", type: .dynamic, targets: ["Apollo_Legacy"]),
    .library(name: "ApolloSQLite_Legacy", targets: ["ApolloSQLite_Legacy"]),
    .library(name: "ApolloWebSocket_Legacy", targets: ["ApolloWebSocket_Legacy"]),
    .library(name: "ApolloTestSupport_Legacy", targets: ["ApolloTestSupport_Legacy"]),
    .plugin(name: "InstallCLI_Legacy", targets: ["Install CLI Legacy"])
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Apollo_Legacy",
      dependencies: [
        "ApolloAPI_Legacy"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloAPI_Legacy",
      dependencies: [],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloSQLite_Legacy",
      dependencies: [
        "Apollo_Legacy",
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloWebSocket_Legacy",
      dependencies: [
        "Apollo_Legacy"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloTestSupport_Legacy",
      dependencies: [
        "Apollo_Legacy",
        "ApolloAPI_Legacy"
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .plugin(
      name: "Install CLI Legacy",
      capability: .command(
        intent: .custom(
          verb: "apollo-cli-install",
          description: "Installs the Apollo iOS Command line interface."),
        permissions: [
          .writeToPackageDirectory(reason: "Downloads and unzips the CLI executable into your project directory."),
          .allowNetworkConnections(scope: .all(ports: []), reason: "Downloads the Apollo iOS CLI executable from the GitHub Release.")
        ]),
      dependencies: [],
      path: "Plugins/InstallCLI_Legacy"
    )
  ]
)
