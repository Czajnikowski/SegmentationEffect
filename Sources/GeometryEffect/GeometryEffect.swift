import SwiftUI

public struct Segment {
  public var step: Step
  public var speed: Float
  
  public init(step: Step, speed: Float) {
    self.step = step
    self.speed = speed
  }
  
  var floatArray: [Float] {
    step.floatArray + [speed]
  }
}

public enum Step {
  case node(SIMD2<Float>)
  case bar(SIMD2<Float>, SIMD2<Float>)
  
  var floatArray: [Float] {
    switch self {
    case .node(let position):
      return position.xy + position.xy
    case .bar(let lPosition, let rPosition):
      return lPosition.xy + rPosition.xy
    }
  }
}

extension View {
  public func geometryEffect(
    segments: [Segment],
    verticalOffset: Float = 0
  ) -> some View {
    compositingGroup()
      .distortionEffect(
        .init(
          function: .init(library: .bundle(.module), name: "geometryEffect"),
          arguments: [
            .boundingRect,
            .floatArray(segments.flatMap(\.floatArray)),
            .float(verticalOffset),
          ]
        ),
        maxSampleOffset: .zero
      )
  }
}

extension SIMD2 {
  var xy: [Scalar] {
    [x, y]
  }
}
