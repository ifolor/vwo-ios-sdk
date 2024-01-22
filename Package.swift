// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VWOSDK",
    products: [
        .library(
            name: "VWOSDK",
            targets: ["VWOSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", "15.2.0"..<"15.2.1")
    ],
    targets: [
        .target(
            name: "VWOSDK",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "VWO/",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Extensions/"),
                .headerSearchPath("Helpers/"),
                .headerSearchPath("MEG/"),
                .headerSearchPath("Models/")
            ]
        )
    ]
)
