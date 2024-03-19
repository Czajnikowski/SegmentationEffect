//
//  PointEditingView.swift
//  GeometryEffectExample
//
//  Created by Maciek Czarnik on 14/03/2024.
//

import SwiftUI

struct PointEditingView: View {
  private enum Constant {
    static let distanceToEditingControls: CGFloat = 40
  }
  
  let offset: CGSize
  let deleteAction: () -> Void
  let addAction: (() -> Void)?
  
  init(
    offset: CGSize,
    deleteAction: @escaping () -> Void,
    addAction: (() -> Void)? = nil
  ) {
    self.offset = offset
    self.deleteAction = deleteAction
    self.addAction = addAction
  }
  
  @State private var isEditing = false
  @State private var endEditingTask: Task<Void, Never>?
  
  var body: some View {
    ZStack {
      HandleView(
        offset: CGSize(
          width: offset.width - Constant.distanceToEditingControls,
          height: offset.height
        )
      )
        .opacity(isEditing ? 1 : 0)
        .foregroundColor(.red.opacity(0.5))
        .onTapGesture(perform: deleteAction)
      
      if let addAction {
        HandleView(
          offset: CGSize(
            width: offset.width + Constant.distanceToEditingControls,
            height: offset.height
          )
        )
          .opacity(isEditing ? 1 : 0)
          .foregroundColor(.green.opacity(0.5))
          .onTapGesture(perform: addAction)
      }
      
      HandleView(offset: offset)
        .foregroundColor(.primary.opacity(0.5))
        .onTapGesture(perform: isEditing ? endEditing : startEditing)
    }
  }
  
  private func startEditing() {
    endEditingTask = Task {
      isEditing = true
      try? await Task.sleep(for: .seconds(2.5))
      isEditing = false
    }
  }
  
  private func endEditing() {
    endEditingTask?.cancel()
    isEditing = false
  }
}

struct HandleView: View {
  private enum Constant {
    static let size: CGFloat = 20
    static var paddedHalfSize: CGFloat { size / 2 + padding }
    static let padding: CGFloat = 10
  }
  
  let offset: CGSize
  
  var body: some View {
    Circle()
      .frame(
        width: Constant.size,
        height: Constant.size
      )
      .padding(.all, Constant.padding)
      .contentShape(Rectangle())
//      .background(Color.blue)
      .offset(
        x: offset.width - Constant.paddedHalfSize,
        y: offset.height - Constant.paddedHalfSize
      )
  }
}
