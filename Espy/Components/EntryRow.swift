//
//  EntryRow.swift
//  EntryRow
//
//  Created by Willie Johnson on 9/10/21.
//

import Foundation
import SwiftUI

struct EntryRow: View {
  @EnvironmentObject var viewModel: MainViewModel

  var entry: Entry
  var action: () -> Void
  var secondaryAction: () -> Void
  var thirdAction: () -> Void

  var isSelected: Bool {
    get {
      viewModel.isEntrySelected(entry)
    }
  }

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          HStack(alignment: .firstTextBaseline) {
            Text(entry.createdAt.shortString())
              .font(.headline).foregroundColor(.accentColor)
            Text("<").font(.headline).foregroundColor(.accentColor)
            Text(entry.updatedAt.shortString())
              .font(.subheadline).foregroundColor(.gray)
          }

          if viewModel.isEditModeOn {
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
    }
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 4 : viewModel.isMultiSelectOn ? 1 : 0)
    )
  }
}
