// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SegmentationEffect",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "SegmentationEffect",
      targets: ["SegmentationEffect"]
    ),
  ],
  targets: [
    .target(
      name: "SegmentationEffect",
      resources: [.process("Shaders/SegmentationEffect.metal")]
    ),
  ]
)
