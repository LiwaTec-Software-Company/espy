//
//  View+Extensions.swift
//  Espy
//
//  Created by Willie Johnson on 9/2/21.
//

import Foundation
import SwiftUI

extension View {
  func Print(_ vars: Any...) -> some View {
    for v in vars { print(v) }
    return EmptyView()
  }
  
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
