//
//  EditView.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import SwiftUI

struct EditView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var cloudManager: CloudManager

  @State var fullText: String = ""
  @State var isTextUpdated: Bool = false
  @State private var currentDate: Date = Date()

  private var originalText: String = ""

  var selectedIndex: Int = 0
  var selectedEntry: Entry = Entry()
  var subheadlineText = ""

  var isNew = true

  init() {}

  init(file: URL, cloudManager: CloudManager) {
    self.init()
    if let entry = cloudManager.getEntry(from: file) {
      self.selectedIndex = entry.index
      self.selectedEntry = entry

      self.isNew = false
      _fullText = State(initialValue: selectedEntry.content)
      originalText = self.fullText
    } else {
      self.init()
    }
  }

  init(index: Int, cloudManager: CloudManager, isNew: Bool = false) {
    self.selectedIndex = index
    self.selectedEntry = cloudManager.entries[selectedIndex]

    self.isNew = isNew
    _fullText = State(initialValue: selectedEntry.content)
    originalText = self.fullText
  }

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      VStack(alignment: .center, spacing: 1) {
        Text(selectedEntry.date.displayDate()).padding(5).font(.title3).foregroundColor(isNew ? .green : .primary)
        Text(selectedEntry.id.uuidString).padding(0).font(.caption).foregroundColor(isNew ? .green : .gray)
        Text(currentDate.formattedStringDate()).padding(5).font(.caption).foregroundColor((isTextUpdated || isNew) ? .green : .gray)
      }
      TextEditor(text: $fullText).cornerRadius(10).padding(10).onChange(of: fullText, perform: { value in
        isTextUpdated = fullText != originalText
        currentDate = Date()
      })
      Button(action: {
        let entry = Entry(entry: selectedEntry, content: fullText)

        if isNew {
          cloudManager.addNewEntry(entry)
        } else if isTextUpdated {
          cloudManager.updateEntry(selectedEntry, new: entry, at: selectedIndex)
        }

        presentationMode.wrappedValue.dismiss()
      }, label: {
        Image(systemName: "chevron.compact.down")
          .font(.system(size: 44.0, weight: .bold)).foregroundColor((isTextUpdated || isNew) ? .green : .accentColor)
      }).padding(20)
    })
  }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
