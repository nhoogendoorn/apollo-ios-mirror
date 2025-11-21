// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "Apollo_Legacy",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "Apollo_Legacy", targets: ["Apollo_Legacy"]),
    .library(name: "ApolloAPI_Legacy", targets: ["ApolloAPI_Legacy"]),
    .library(name: "Apollo-Dynamic_Legacy", type: .dynamic, targets: ["Apollo_Legacy"]),
    .library(name: "ApolloSQLite_Legacy", targets: ["ApolloSQLite_Legacy"]),
    .library(name: "ApolloWebSocket_Legacy", targets: ["ApolloWebSocket_Legacy"]),
    .library(name: "ApolloTestSupport_Legacy", targets: ["ApolloTestSupport_Legacy"]),
    .plugin(name: "InstallCLI_Legacy", targets: ["Install CLI"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Apollo_Legacy",
      dependencies: [
        "ApolloAPI_Legacy"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "ApolloAPI_Legacy",
      dependencies: [],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "ApolloSQLite_Legacy",
      dependencies: [
        "Apollo_Legacy",
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "ApolloWebSocket_Legacy",
      dependencies: [
        "Apollo_Legacy"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "ApolloTestSupport_Legacy",
      dependencies: [
        "Apollo_Legacy",
        "ApolloAPI_Legacy"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .plugin(
      name: "Install CLI",
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
  ],
  swiftLanguageModes: [.v6, .v5]
)
