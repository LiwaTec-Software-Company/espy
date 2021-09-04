//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI
import MarkdownUI

class ContentManager: ObservableObject {
  static let shared = ContentManager()
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
      entriesSelected.count == EntryManager.shared.entryMap.count
    }
  }

  func isEntrySelected(_ entry: Entry) -> Bool {
    return entriesSelected.contains(entry)
  }

  func toggleSelect(_ entry: Entry) {
    if entriesSelected.contains(entry) {
      entriesSelected.removeAll(where: { $0 == entry })
    }
    else {
      entriesSelected.append(entry)
    }
  }

  func unselectAll() {
    entriesSelected.removeAll()
  }

  func unselect(_ entry: Entry) {
    entriesSelected.removeAll(where: { $0 == entry })
  }

  func select(_ entry: Entry) {
    if !entriesSelected.contains(entry) {
      entriesSelected.append(entry)
    }
  }
}

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
    // tap > dtap > long
    let longTapGesture = LongPressGesture(minimumDuration: 0.5).onEnded { _ in
      secondaryAction()
    }
    
    let doubleTapGesture = TapGesture(count: 2).onEnded { _ in
      thirdAction()
    }


    let tapGesture = TapGesture().onEnded { _ in
      action()
    }

    let longAndTap = tapGesture.exclusively(before: longTapGesture)

    let tapBeforeDoubleGesture = longAndTap.sequenced(before: doubleTapGesture)

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
      .gesture(tapBeforeDoubleGesture)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 4 : contentManager.isMultiSelectOn ? 1 : 0)
    )
    .offset(
      x: viewState.width + translation.width,
      y: viewState.height + translation.height
    )
    //    .gesture(magnificationAndDragGesture).rotationEffect(Angle(degrees: degrees)).scaleEffect(scale).animation(.easeInOut)
  }
}

struct TrashButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: contentManager.isAnythingSelected ? "trash.fill": "trash")
          .font(Font.system(size: (contentManager.isAnythingSelected || contentManager.isMultiSelectOn) ? 25 : 20))
          .foregroundColor(contentManager.isAnythingSelected ? .red : .gray)
        Text("")
      }).disabled(!(contentManager.isMultiSelectOn || contentManager.isAnythingSelected ))
    }
  }
}

struct EditModeButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var body: some View {
    HStack{
      Button(action: {
        contentManager.isEditModeOn.toggle()
      }, label: {
        Image(systemName: contentManager.isEditModeOn ? "doc.richtext" : "doc.richtext.fill")
          .font(Font.system(size: 25))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}


struct BlockModeButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: (contentManager.isEverythingSelected && contentManager.isMultiSelectOn) ? "xmark.circle.fill" : contentManager.isMultiSelectOn ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
          .font(Font.system(size: 25))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}

struct ContentView: View {
  @ObservedObject var contentManager: ContentManager = ContentManager.shared
  @ObservedObject private var entryManager = EntryManager.shared

  @State private var isShowingEntrySheet = false
  @State private var isShowingBottomSheet = true
  @State private var isShowingDocSheet = false
  @State private var isShowingDocEntrySheet = false

  @State private var currentEntry: Entry?

  private var canShowSheetForEntry: Binding<Bool> {
    Binding (
      get: {
        if let currentEntry = currentEntry {
         return isShowingDocSheet && contentManager.isEntrySelected(currentEntry)
        }
        return false
      },
      set: { $0 }
    )
  }

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
        VStack {
          ForEach(entryManager.entryMap.sorted(by: {$0.key > $1.key}), id: \.value) { entry, id in
            EntryRow(entry: entry, action: {
              selectRow(with: entry)
              if !contentManager.isMultiSelectOn {
                currentEntry = entry
                isShowingEntrySheet.toggle()
              }
            }, secondaryAction: {
              contentManager.isMultiSelectOn.toggle()
            }, thirdAction: {
              contentManager.isEditModeOn.toggle()
            })
            .padding(contentManager.isMultiSelectOn ? 10 : 0)
            .sheet(item: $currentEntry) { entry in
              EditView(entry).onDisappear(perform: unselectAllRows)
            }
          }
          .onDelete(perform: onDelete)
        }
      }
      .onAppear {
        LocalManager.shared.loadAllEntryFiles()
        isShowingBottomSheet = true
      }
      .toolbar {
        ToolbarItem(placement: .destructiveAction) {
          TrashButton(onPress: {
            if contentManager.isMultiSelectOn {
              deleteAllSelectedEntries()
              contentManager.isMultiSelectOn.toggle()
            }
          })
        }

        ToolbarItem(placement: .principal) {
          BlockModeButton(onPress: {
            if contentManager.isEverythingSelected && contentManager.isMultiSelectOn {
              contentManager.isMultiSelectOn.toggle()
              selectAllRows()
            } else if contentManager.isMultiSelectOn {
              selectAllRows()
            } else {
              contentManager.isMultiSelectOn.toggle()
            }
          })
        }

        ToolbarItem(placement: .navigationBarLeading) {
          EditModeButton()
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
                unselectAllRows()
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
              EditView().onDisappear {
                unselectAllRows()
              }
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
    LocalManager.shared.deleteEntriesAndFiles(entriesToDelete)
  }

  func deleteAllSelectedEntries() {
    LocalManager.shared.deleteEntriesAndFiles(contentManager.entriesSelected)
    contentManager.entriesSelected.removeAll()
  }

  func selectRow(with entry: Entry) {
    contentManager.toggleSelect(entry)
  }
  

  func selectAllRows() {
    if contentManager.entriesSelected.count == entryManager.entryMap.count {
      contentManager.entriesSelected.removeAll()
    } else {
      contentManager.entriesSelected = EntryManager.shared.entries
    }
  }

  func unselectAllRows() {
    contentManager.entriesSelected.removeAll()
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
    Markdown("\(line)").disabled(true)
  }

  static func == (lhs: MarkdownLine, rhs: MarkdownLine) -> Bool {
    return lhs.id == rhs.id && lhs.line == rhs.line
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
