//
//  EntryRow.swift
//  EntryRow
//
//  Created by Willie Johnson on 9/10/21.
//

import Foundation
import SwiftUI

struct EntryRow: View {
  @EnvironmentObject var contentManager: ContentManager

  var entry: Entry
  var action: () -> Void
  var secondaryAction: () -> Void
  var thirdAction: () -> Void

  var isSelected: Bool {
    get {
      contentManager.isEntrySelected(entry)
    }
  }

  @State private var degrees: Double = 0
  @State private var scale: CGFloat = 1.0
  @State private var viewState = CGSize.zero
  @State private var translation: CGSize = .zero
  @State private var canBeDragged: Bool = true

  var body: some View {
    let tapGesture = TapGesture().onEnded { _ in
      action()
    }

    Button(action: {}) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          HStack(alignment: .firstTextBaseline) {
            Text(entry.createdAt.shortString())
              .font(.headline).foregroundColor(.accentColor)
            Text("<").font(.headline).foregroundColor(.accentColor)
            Text(entry.updatedAt.shortString())
              .font(.subheadline).foregroundColor(.gray)
          }

          if contentManager.isEditModeOn {
            Text(entry.contents)
              .font(.callout)
              .foregroundColor(.gray)
              .multilineTextAlignment(.leading)
          } else {
            let markdownLines: [MarkdownLine] = entry.formatted.components(separatedBy: .newlines).map { line in
              return MarkdownLine(line: line)
            }
            VStack(alignment: .leading) {
              ForEach(markdownLines, id: \.self) { (markdownLine: MarkdownLine) in
                markdownLine
                  .multilineTextAlignment(.leading)
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding()
      .background(Color.black)
      .gesture(tapGesture)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 4 : contentManager.isMultiSelectOn ? 1 : 0)
    )
    .offset(
      x: viewState.width + translation.width,
      y: viewState.height + translation.height
    )
  }
}
