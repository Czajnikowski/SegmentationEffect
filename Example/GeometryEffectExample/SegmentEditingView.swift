//
//  SegmentEditingView.swift
//  GeometryEffectExample
//
//  Created by Maciek Czarnik on 13/03/2024.
//

import SwiftUI
import GeometryEffect

struct SegmentEditingView: View {
  private enum Constant {
    static let newPointBOffset: CGFloat = 60
  }
  
  @Binding var segment: Segment
  let deleteAction: () -> Void
  
  @State private var dragLocation: CGPoint?
  
  var body: some View {
    let pointA = ZStack(alignment: .topLeading) {
      Slider(value: $segment.speed, in: 0.001 ... 5)
        .offset(y: segment.step.aOffset.height)
        .padding()
        .opacity(0.5)
      PointEditingView(
        offset: segment.step.aOffset,
        deleteAction: {
          if let bOffset = segment.step.bOffset {
            segment.step.mutableAOffset = bOffset
            segment.step.mutableBOffset = nil
          } else {
            deleteAction()
          }
        },
        addAction: segment.step.bOffset.map { _ in nil } ?? {
          segment.step.mutableBOffset = .init(
            width: segment.step.aOffset.width + Constant.newPointBOffset,
            height: segment.step.aOffset.height
          )
        }
      )
      .gesture(
        DragGesture()
          .onChanged { value in
            segment.step.mutableAOffset = .init(
              width: value.location.x,
              height: value.location.y
            )
          }
      )
    }
    
    switch segment.step {
    case .node:
      pointA
    case .bar:
      ZStack(alignment: .topLeading) {
        pointA
        if let bOffset = segment.step.bOffset {
          PointEditingView(
            offset: bOffset,
            deleteAction: { segment.step.mutableBOffset = nil }
          )
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                segment.step.mutableBOffset = .init(
                  width: value.location.x,
                  height: value.location.y
                )
              }
          )
        }
      }
      .background {
        if let bOffset = segment.step.bOffset {
          Path { path in
            path.move(to: .init(x: segment.step.aOffset.width, y: segment.step.aOffset.height))
            path.addLine(to: .init(x: bOffset.width, y: bOffset.height))
          }
          .stroke(.black.opacity(0.5))
        }
      }
    }
  }
}

extension Step {
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

extension Step {
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
