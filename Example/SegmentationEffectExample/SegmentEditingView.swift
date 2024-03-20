//
//  SegmentEditingView.swift
//  SegmentationEffectExample
//
//  Created by Maciek Czarnik on 13/03/2024.
//

import SwiftUI
import SegmentationEffect

struct SegmentEditingView: View {
  private enum Constant {
    static let newPointBOffset: CGFloat = 60
  }
  
  @Binding var segment: Segment
  let deleteAction: () -> Void
  
  @State private var dragLocation: CGPoint?
  
  var body: some View {
    let pointA = ZStack(alignment: .topLeading) {
      Slider(value: $segment.contentScale, in: 0.001 ... 5)
        .offset(y: segment.bottomEdge.aOffset.height)
        .padding()
        .opacity(0.5)
      PointEditingView(
        offset: segment.bottomEdge.aOffset,
        deleteAction: {
          if let bOffset = segment.bottomEdge.bOffset {
            segment.bottomEdge.mutableAOffset = bOffset
            segment.bottomEdge.mutableBOffset = nil
          } else {
            deleteAction()
          }
        },
        addAction: segment.bottomEdge.bOffset.map { _ in nil } ?? {
          segment.bottomEdge.mutableBOffset = .init(
            width: segment.bottomEdge.aOffset.width + Constant.newPointBOffset,
            height: segment.bottomEdge.aOffset.height
          )
        }
      )
      .gesture(
        DragGesture()
          .onChanged { value in
            segment.bottomEdge.mutableAOffset = .init(
              width: value.location.x,
              height: value.location.y
            )
          }
      )
    }
    
    switch segment.bottomEdge {
    case .node:
      pointA
    case .bar:
      ZStack(alignment: .topLeading) {
        pointA
        if let bOffset = segment.bottomEdge.bOffset {
          PointEditingView(
            offset: bOffset,
            deleteAction: { segment.bottomEdge.mutableBOffset = nil }
          )
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                segment.bottomEdge.mutableBOffset = .init(
                  width: value.location.x,
                  height: value.location.y
                )
              }
          )
        }
      }
      .background {
        if let bOffset = segment.bottomEdge.bOffset {
          Path { path in
            path.move(to: .init(x: segment.bottomEdge.aOffset.width, y: segment.bottomEdge.aOffset.height))
            path.addLine(to: .init(x: bOffset.width, y: bOffset.height))
          }
          .stroke(.black.opacity(0.5))
        }
      }
    }
  }
}

extension SegmentationEffect.Edge {
  var aOffset: CGSize {
    switch self {
    case .node(let floats):
      return .init(with: floats)
    case .bar(let floats, _):
      return .init(with: floats)
    }
  }
  
  var bOffset: CGSize? {
    switch self {
    case .node:
      return nil
    case .bar(_, let floats):
      return .init(with: floats)
    }
  }
}

extension SegmentationEffect.Edge {
  var mutableAOffset: CGSize {
    get {
      aOffset
    }
    set {
      switch self {
      case .node:
        self = .node(newValue.float2)
      case .bar(_, let floats):
        self = .bar(newValue.float2, floats)
      }
    }
  }
  
  var mutableBOffset: CGSize? {
    get {
      bOffset
    }
    set {
      if let newValue {
        self = .bar(aOffset.float2, newValue.float2)
      } else {
        self = .node(aOffset.float2)
      }
    }
  }
}
