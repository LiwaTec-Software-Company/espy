//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI
import MarkdownUI

class ContentManager: ObservableObject {
  @Published var isMultiSelectOn: Bool = false
  @Published var isEditModeOn: Bool = false
  @Published var entriesSelected: [Entry] = []

  var isAnythingSelected: Bool {
    get {
      entriesSelected.count > 0
    }
  }

  var isMultipleSelected: Bool {
    get {
      entriesSelected.count > 1
    }
  }

  var isEverythingSelected: Bool {
    get {
      entriesSelected.count == EntryManager.shared.entries.count
    }
  }

  func isEntrySelected(_ entry: Entry) -> Bool {
    return entriesSelected.contains(entry)
  }
}

struct EntryRow: View {
  @EnvironmentObject var contentManager: ContentManager

  var entry: Entry
  var action: () -> Void
  var secondaryAction: () -> Void

  var isSelected: Bool {
    get {
      contentManager.isEntrySelected(entry)
    }
  }

  var body: some View {
    Button(action: {}) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          HStack(alignment: .firstTextBaseline) {
            Text(entry.date.shortString())
              .font(.caption).foregroundColor(.accentColor)
            Spacer()
            Text(entry.lastUpdated.shortString())
              .font(.caption).foregroundColor(.gray)
          }
          let markdownLines: [MarkdownLine] = entry.content.components(separatedBy: .newlines).map { line in
            return MarkdownLine(line: line)
          }

          if contentManager.isEditModeOn {
            Text(entry.content)
          } else {
            Group {
              ForEach(markdownLines, id: \.self) { (markdownLine: MarkdownLine) in
                markdownLine
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(Color.black)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 4 : contentManager.isMultiSelectOn ? 1 : 0)
    )
    .simultaneousGesture(
      LongPressGesture(minimumDuration: 1).onEnded { _ in
        secondaryAction()
      }
    )
    .highPriorityGesture(
      TapGesture().onEnded { _ in
        action()
      }
    )
  }
}

struct ContentView: View {
  @StateObject var contentManager: ContentManager = ContentManager()
  @ObservedObject private var entryManager = EntryManager.shared

  @State private var isShowingEntrySheet = false
  @State private var isShowingBottomSheet = true
  @State private var isShowingDocSheet = false
  @State private var isShowingDocEntrySheet = false

  @State var editViewFromDocSheet: EditView?

  var isMultiSelectOn: Bool {
    get {
      contentManager.isMultiSelectOn
    }
  }

  init() {
    let barBackgroundImage = UIImage(color: UIColor(hue: 0, saturation: 1, brightness: 0, alpha: 0.7))
    UINavigationBar.appearance().barTintColor = .clear
    UINavigationBar.appearance().setBackgroundImage(barBackgroundImage, for: .default)
    UIToolbar.appearance().barTintColor = .clear
    UIToolbar.appearance().setBackgroundImage(barBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
  }

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack {
          ForEachWithIndex(entryManager.entries) { (index: Int, entry: Entry) in
            EntryRow(entry: entry, action: {
              if contentManager.isMultiSelectOn {
                selectRow(with: entry)
              } else {
                isShowingEntrySheet.toggle()
              }
            }, secondaryAction: {
              contentManager.isMultiSelectOn.toggle()
            })
            .padding(contentManager.isMultiSelectOn ? 10 : 0)
            .sheet(isPresented: $isShowingEntrySheet) {
              EditView(index: index)
            }
          }
          .onDelete(perform: onDelete)
          .onMove(perform: onMove)
        }
      }
      .onAppear {
        LocalManager.shared.loadAllEntryFiles()
        isShowingBottomSheet = true
      }
      .toolbar {
        ToolbarItem(placement: .destructiveAction) {
          HStack{
            Button(action: {
              if contentManager.isMultiSelectOn {
                deleteAllSelectedEntries()

                contentManager.isMultiSelectOn.toggle()
              }
            }, label: {
              Image(systemName: contentManager.isAnythingSelected ? "trash.fill": "trash")
                .font(Font.system(size: contentManager.isMultiSelectOn ? 25 : 20))
                .foregroundColor(contentManager.isAnythingSelected ? .red : .gray)
              Text("")
            }).disabled(!contentManager.isMultiSelectOn)
          }
        }

        ToolbarItem(placement: .principal) {
          HStack{
            Button(action: {
              if contentManager.isEverythingSelected && contentManager.isMultiSelectOn {
                contentManager.isMultiSelectOn.toggle()
                selectAllRows()
              } else if contentManager.isMultiSelectOn {
                selectAllRows()
              } else {
                contentManager.isMultiSelectOn.toggle()
              }
            }, label: {
              Image(systemName: (contentManager.isEverythingSelected && contentManager.isMultiSelectOn) ? "xmark.circle.fill" : contentManager.isMultiSelectOn ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                .font(Font.system(size: 25))
                .foregroundColor(.accentColor)
              Text("")
            })
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          HStack{
            Button(action: {
              if contentManager.isEverythingSelected && contentManager.isMultiSelectOn {
                contentManager.isMultiSelectOn.toggle()
                selectAllRows()
              } else if contentManager.isMultiSelectOn {
                selectAllRows()
              } else {
                contentManager.isMultiSelectOn.toggle()
              }

              contentManager.isEditModeOn.toggle()
            }, label: {
              Image(systemName: contentManager.isMultipleSelected ? "tag.fill" : "tag")
                .font(Font.system(size: 25))
                .foregroundColor(.accentColor)
              Text("")
            })
          }
        }

        ToolbarItemGroup(placement: .bottomBar) {
          Button(action: {
            isShowingDocSheet.toggle()
          }) {
            Image(systemName: "folder")
          }.sheet(isPresented: $isShowingDocSheet, content: {
            DocumentPicker { url in
              self.editViewFromDocSheet = EditView(file: url)
              isShowingDocEntrySheet.toggle()
            }.onDisappear {
              LocalManager.shared.loadAllEntryFiles()
            }
          }).sheet(isPresented: $isShowingDocEntrySheet) {
            if let editView = editViewFromDocSheet {
              editView.onDisappear {
                self.editViewFromDocSheet = nil
                isShowingDocSheet = false
              }
            }
          }
          Spacer()
          HStack {
            Button(action: {
              isShowingBottomSheet.toggle()
            }) {
              Image(systemName: "chevron.compact.up")
                .font(.system(size: 44.0, weight: .bold))
            }
            .sheet(isPresented: $isShowingBottomSheet) {
              EditView()
            }
            Text("")
          }
          Spacer()
          Button(action: {
            print("Edit button was tapped")
          }) {
            Image(systemName: contentManager.isMultipleSelected ? "paperplane.fill" : "paperplane")
          }
        }
      }
    }
    .environmentObject(contentManager)
  }

  func onDelete(at offsets: IndexSet) {
    // preserve all ids to be deleted to avoid indices confusing
    let entriesToDelete = offsets.map { entryManager.entries[$0] }
    LocalManager.shared.deleteEntryFiles(entriesToDelete)
  }

  private func onMove(source: IndexSet, destination: Int) {
    entryManager.entries.move(fromOffsets: source, toOffset: destination)
  }

  func deleteAllSelectedEntries() {
    LocalManager.shared.deleteEntryFiles(contentManager.entriesSelected)
    contentManager.entriesSelected.removeAll()
  }

  func selectRow(with entry: Entry) {
    if contentManager.entriesSelected.contains(entry) {
      contentManager.entriesSelected.removeAll(where: { $0 == entry })
    }
    else {
      contentManager.entriesSelected.append(entry)
    }
  }

  func selectAllRows() {
    if contentManager.entriesSelected.count == entryManager.entries.count {
      contentManager.entriesSelected.removeAll()
    } else {
      contentManager.entriesSelected = EntryManager.shared.entries
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


struct MarkdownLine: View, Identifiable, Hashable {
  @State var line: String = ""
  let id: UUID = UUID()

  var body: some View {
    Markdown("\(line)")
  }

  static func == (lhs: MarkdownLine, rhs: MarkdownLine) -> Bool {
    return lhs.id == rhs.id && lhs.line == rhs.line
  }

  func hash(into hasher: inout Hasher) {
      hasher.combine(id)
  }
}
