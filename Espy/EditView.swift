//
//  EditView.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import SwiftUI

struct EditView: View {
  @Environment(\.presentationMode) var presentationMode

  @State var fullText: String = "# "
  @State var isTextUpdated: Bool = false
  @State private var currentDate: Date = Date()

  private var originalText: String = ""

  var selectedID: UUID {
    get {
      self.selectedEntry.id
    }
  }

  var selectedEntry: Entry = Entry()

  var isNew = true

  init() {}

  init(_ entry: Entry, isNew: Bool = false) {
    self.init()
    self.selectedEntry = entry

    self.isNew = isNew
    _fullText = State(initialValue: selectedEntry.content)
    originalText = self.fullText
  }

  init(file: URL) {
    if let entry = LocalManager.shared.getLocalEntry(with: file) {
      self.init(entry)
    } else {
      self.init()
    }
  }

  init(id: UUID, isNew: Bool = false) {
    if let entry = EntryManager.shared.getEntry(with: id) {
      self.init(entry, isNew: isNew)
    } else {
      self.init()
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      HStack {
        EditModeButton()
        Spacer()
        VStack(alignment: .center, spacing: 1) {
          Text(selectedEntry.date.displayDate()).padding(5).font(.title3).foregroundColor(isNew ? .green : .primary)
          Text(selectedEntry.id.uuidString).padding(0).font(.caption).foregroundColor(isNew ? .green : .gray)
          Text(currentDate.formattedStringDate()).padding(5).font(.caption).foregroundColor((isTextUpdated || isNew) ? .green : .gray)
        }
        Spacer()
        TrashButton(onPress: {
          if (!isNew) {
            ContentManager.shared.unselect(selectedEntry)
            LocalManager.shared.deleteEntryAndFile(selectedEntry)
            presentationMode.wrappedValue.dismiss()
          }
        })
      }

      TextEditor(text: $fullText).cornerRadius(10).padding(10).onChange(of: fullText, perform: { value in
        isTextUpdated = fullText != originalText
        currentDate = Date()
      })

      Button(action: {
        let entry = Entry(entry: selectedEntry, content: fullText)

        if isNew {
          LocalManager.shared.createFileFor(entry)
        } else if isTextUpdated {
          LocalManager.shared.updateEntryAndFile(with: selectedID)
        }

        ContentManager.shared.unselect(selectedEntry)
        presentationMode.wrappedValue.dismiss()
      }, label: {
        Image(systemName: "chevron.compact.down")
          .font(.system(size: 44.0, weight: .bold)).foregroundColor((isTextUpdated || isNew) ? .green : .accentColor)
      })
      .padding(20)
    })
    .onAppear(perform: {
      if (!isNew) {
        ContentManager.shared.select(selectedEntry)
      }
    })
  }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
