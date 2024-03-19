//
//  CoreGraphics+.swift
//  SegmentationEffectExample
//
//  Created by Maciek Czarnik on 18/03/2024.
//

import CoreGraphics

extension CGSize {
  static func all(_ size: CGFloat) -> Self {
    .init(width: size, height: size)
  }
}

extension CGPoint {
  var float2: SIMD2<Float> {
    .init(Float(x), Float(y))
  }
}

extension CGSize {
  var float2: SIMD2<Float> {
    .init(Float(width), Float(height))
  }
  
  init(with float2: SIMD2<Float>) {
    self.init(width: CGFloat(float2.x), height: CGFloat(float2.y))
  }
}
