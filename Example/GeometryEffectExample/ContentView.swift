//
//  ContentView.swift
//  GeometryEffectExample
//
//  Created by Maciek Czarnik on 05/03/2024.
//

import SwiftUI
import GeometryEffect
import IdentifiedCollections

struct ContentView: View {
  @State private var segments: [Identified<UUID, Segment>] = []
  
  @GestureState private var verticalDragTranslation: CGFloat?
  @State private var verticalDragStartOffset: Float?
  
  @State private var isInEditingMode = false
  private var editingUIOpacity: CGFloat {
    isInEditingMode ? 1 : 0
  }
  
  @State private var startDate = Date.now
  
  var body: some View {
    TimelineView(.animation) { timelineContext in
      Rectangle()
        .fill(.background.opacity(0.001))
        .overlay {
          VStack(alignment: .leading) {
            Text("Hello,")
              .padding(-16)
            Text("world!")
              .padding(-16)
          }
          .font(.system(size: 140).weight(.black))
          .padding(.horizontal, 32)
        }
        .border(.red.opacity(editingUIOpacity).opacity(0.6), width: 4)
        .overlay(alignment: .center) {
          Group {
            Rectangle().frame(width: 4)
            Rectangle().frame(height: 4)
          }
          .opacity(0.6)
          .opacity(editingUIOpacity)
        }
        .geometryEffect(
          segments: segments.map(\.value),
          verticalOffset: verticalOffset(timelineContext)
        )
        .gesture(
          DragGesture(minimumDistance: 8)
            .onChanged { _ in
              if verticalDragTranslation == nil {
                verticalDragStartOffset = verticalOffset(timelineContext)
              }
            }
            .updating($verticalDragTranslation) { value, state, _ in
              state = value.translation.height
            }
        )
    }
    .onTapGesture(perform: isInEditingMode ? addNode : ignore)
    .overlay(alignment: .topLeading) {
      ForEach($segments) { $segment in
        SegmentEditingView(
          segment: $segment.value,
          deleteAction: { segments.removeAll(where: { $0.id == $segment.id }) }
        )
        .opacity(editingUIOpacity)
      }
    }
    .ignoresSafeArea()
    .overlay(alignment: .bottomTrailing) {
      VStack(spacing: 8) {
        Button(action: restart) {
          Image(systemName: "arrow.circlepath")
            .padding()
            .background(
              RoundedRectangle(cornerSize: .all(8))
                .fill(.white.opacity(0.5))
            )
        }
        .opacity(editingUIOpacity)
        
        Button(action: { isInEditingMode.toggle() }) {
          Image(systemName: "skew")
            .padding()
            .background(
              RoundedRectangle(cornerSize: .all(8))
                .fill((isInEditingMode ? Color.red : .white.opacity(0.5)))
            )
            .opacity(isInEditingMode ? 1 : 0.5)
        }
      }
      .font(.system(size: 24))
      .padding()
    }
    .onAppear(perform: restart)
    .tint(.black)
  }
  
  private func verticalOffset(_ timelineContext: TimelineViewDefaultContext) -> Float {
    guard let verticalDragTranslation, let verticalDragStartOffset else {
      return Float(timelineContext.date.timeIntervalSince(startDate))
    }
    
    return verticalDragStartOffset + Float(verticalDragTranslation) / 10
  }
  
  private func addNode(at point: CGPoint) {
    let newSegment = Identified<UUID, Segment>(.init(step: .node(point.float2), speed: 1), id: .init())
    segments.insert(newSegment, at: segments.firstIndex(where: { $0.step.aOffset.height < point.y}) ?? segments.count)
  }
  
  private func restart() {
    segments = []
    startDate = .now
  }
}

#Preview {
  ContentView()
}
