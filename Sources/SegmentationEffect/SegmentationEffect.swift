import SwiftUI

public struct Segment {
  public var bottomEdge: Edge
  
  public var contentScale: Float
  
  public init(bottomEdge: Edge, contentScale: Float) {
    self.bottomEdge = bottomEdge
    self.contentScale = contentScale
  }
  
  var floatArray: [Float] {
    bottomEdge.floatArray + [contentScale]
  }
}

public enum Edge {
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
  public func segmentationEffect(
    segments: [Segment],
    verticalOffset: Float = 0
  ) -> some View {
    compositingGroup()
      .distortionEffect(
        .init(
          function: .init(library: .bundle(.module), name: "segmentationEffect"),
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
