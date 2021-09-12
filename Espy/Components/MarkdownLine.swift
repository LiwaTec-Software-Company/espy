//
//  MarkdownLine.swift
//  MarkdownLine
//
//  Created by Willie Johnson on 9/10/21.
//

import Foundation
import SwiftUI
import MarkdownUI

struct MarkdownLine: View, Identifiable, Hashable {
  @State var line: String = ""
  let id: UUID = UUID()

  var body: some View {
    Markdown("\(line)").disabled(true)
  }

  static func == (lhs: MarkdownLine, rhs: MarkdownLine) -> Bool {
    return lhs.id == rhs.id && lhs.line == rhs.line
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

