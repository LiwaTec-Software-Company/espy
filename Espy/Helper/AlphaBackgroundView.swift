//
//  Sheets.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation
import SwiftUI

struct AlphaBackgroundView: UIViewRepresentable {
  var alpha: CGFloat

  init(alpha: CGFloat = 0.8) {
    self.alpha = alpha
  }

  func makeUIView(context: Context) -> some UIView {
    let view = UIView()
    DispatchQueue.main.async {
      view.superview?.superview?.backgroundColor = UIColor.init(.black).withAlphaComponent(alpha)
    }
    return view
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
  }
}

struct AlphaBackgroundViewModifier: ViewModifier {
  var alpha: CGFloat

  init(alpha: CGFloat = 0.8) {
    self.alpha = alpha
  }

  func body(content: Content) -> some View {
    content
      .background(AlphaBackgroundView(alpha: alpha))
  }
}

extension View {
  func alphaModalBackground(alpha: CGFloat = 0.8) -> some View {
    self.modifier(AlphaBackgroundViewModifier(alpha: alpha))
  }
}
