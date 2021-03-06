  //
  //  EditView.swift
  //  Espy
  //
  //  Created by Willie Johnson on 9/1/21.
  //

import SwiftUI

@available(iOS 15.0, *)
struct EditView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var mainManager: MainManager
  @EnvironmentObject var contentManager: ContentManager
  @EnvironmentObject var entryManger: EntryManager

  @FocusState private var isEditingText: Bool
  @State var fullText: String = "# "
  @State var isTextUpdated: Bool = false
  @State private var currentDate: Date = Date()

  @State private var activeFont: UIFont = .systemFont(ofSize: 18, weight: .regular)

  private var originalText: String = ""

  var selectedID: UUID {
    get {
      self.selectedEntry.id
    }
  }

  var selectedEntry: Entry = Entry()

  var isNew = true

  init() {
    isEditingText = isNew
  }

  init(_ entry: Entry, isNew: Bool = false) {
    self.init()
    self.selectedEntry = entry

    self.isNew = isNew
    _fullText = State(initialValue: selectedEntry.getContentsWithoutMeta())
    originalText = self.fullText
  }

  init(url: URL) {
    self.init(MainManager.shared.getEntry(with: url))
  }

  init(id: UUID, isNew: Bool = false) {
    if let entry = MainManager.shared.getEntry(with: id) {
      self.init(entry, isNew: isNew)
    } else {
      self.init()
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
        // Header
      HStack {
        TrashButton(onPress: {
          if (!isNew) {
            contentManager.unselect(selectedEntry)
            mainManager.delete(entry: selectedEntry)
            presentationMode.wrappedValue.dismiss()
          }
        })
        Spacer()
        Text(selectedEntry.createdAt.displayDate()).padding(5).font(.title3).foregroundColor(isNew ? .green : .primary)
        Spacer()
        EditModeButton()
      }.padding()

      ZStack(alignment: .bottomLeading) {
        QuickTextEditor(text: $fullText, activeFont: $activeFont, placeholder: "# Untitled") { value in
          isTextUpdated = fullText != originalText
          currentDate = Date()
        }
        .focused($isEditingText)
        .cornerRadius(10)
        .padding(10)
          // Footer
        VStack(alignment: .center) {
          Text(selectedEntry.id.uuidString).font(.subheadline).foregroundColor(isNew ? .green : .gray).lineLimit(1)
          HStack {
            ImportButton(onPress: {
              print("eh")
            })
            VStack(alignment: .center, spacing: 1) {
              Text(currentDate.formattedStringDate()).font(.caption).foregroundColor((isTextUpdated || isNew) ? .green : .gray)
              Button(action: {
                if isNew {
                  self.selectedEntry.update(with: fullText)
                  mainManager.add(entry: selectedEntry)
                } else if isTextUpdated {
                  mainManager.update(entry: selectedEntry, with: fullText)
                }
                contentManager.unselect(selectedEntry)
                presentationMode.wrappedValue.dismiss()
              }, label: {
                Image(systemName: "chevron.compact.down")
                  .font(.system(size: 44.0, weight: .bold)).foregroundColor((isTextUpdated || isNew) ? .green : .accentColor)
              })
                .padding(10)
            }
            .frame(maxWidth: .infinity)

            ExportButton()
          }
        }
        .padding(10)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding(10)

      }
    })
      .onAppear(perform: {
        if (!isNew) {
          contentManager.select(selectedEntry)
        }
      })
  }
}

@available(iOS 15.0, *)
struct EditView_Previews: PreviewProvider {
  static var previews: some View {
    EditView()
  }
}
