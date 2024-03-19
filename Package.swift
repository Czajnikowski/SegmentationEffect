// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GeometryEffect",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "GeometryEffect",
      targets: ["GeometryEffect"]
    ),
  ],
  targets: [
    .target(
      name: "GeometryEffect",
      resources: [.process("Shaders/GeometryEffect.metal")]
    ),
  ]
)
