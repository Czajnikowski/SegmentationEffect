import SwiftUI

extension View {
  /// Applies an effect that renders the content of the modified `View` as a top-to-bottom series of quadrilateral segments.
  ///
  /// - Parameters:
  ///   - segments: an array of ``Segment`` instances defining the segmentation of the modified view.
  ///   - verticalOffset: a vertical offset of content provided by a modified view. You can use it to animate your content.
  /// - Returns: A view with applied effect.
  ///
  /// The first segment to be rendered gets constructed from coordinates of the top-right and top-left corners of the view and the `bottomEdge` of the first ``Segment`` in the `segments` array. Each next segment gets rendered in relation to the previous one, so the `bottomEdge` of the previous segment becomes a top edge of the next one. The final segment gets rendered using the last segment's `bottomEdge` as a top edge and coordinates of the bottom-left and bottom-right corners of the view.
  ///
  /// If the `segments` array is empty, the geometry of modified view gets rendered unchanged.
  /// 
  /// Segments are rendered in a top-to-bottom order, so if you have any overlaping segments the one with the lower index in the `segments` array will occlude the one with the higher index.
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

/// `Segment` models a segment of rendered content.
public struct Segment {
  /// Defines the bottom edge of the segment.
  ///
  /// Segments are always rendered "under" an existing segment or edge (see the discussion section under ``SwiftUI/View/segmentationEffect(segments:verticalOffset:)``), so the `bottomEdge` is the only thing needed to define the geometry of a segment.
  public var bottomEdge: Edge
  
  /// This parameter decides how "expanded" or "stretched" is the content inside the segment.
  public var contentScale: Float
  
  public init(bottomEdge: Edge, contentScale: Float) {
    self.bottomEdge = bottomEdge
    self.contentScale = contentScale
  }
  
  var floatArray: [Float] {
    bottomEdge.floatArray + [contentScale]
  }
}

/// `Edge` models a place where two segments meet.
///
/// It defines vertices using `SIMD2<Float>` `x`, `y` values in SwiftUI coordinate space ((0,0) in the top-left corner).
public enum Edge {
  /// A `node` models a single-vertex edge.
  case node(SIMD2<Float>)
  /// A `bar` models an edge that consists of two vertices.  To model a twisted segment make sure that the `x` value of the first vertex is greater than the `x` value of the second one.
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

