//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI
import MarkdownUI


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
            Text(entry.createdAt.shortString())
              .font(.caption).foregroundColor(.accentColor)
            Spacer()
            Text(entry.updatedAt.shortString())
              .font(.caption).foregroundColor(.gray)
          }
          let markdownLines: [MarkdownLine] = entry.formatted.components(separatedBy: .newlines).map { line in
            return MarkdownLine(line: line)
          }

          if contentManager.isEditModeOn {
            Text(entry.formatted)
            Text("\n\(entry.file.formattedStringTags())")
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
  @ObservedObject private var mainManager: MainManager = MainManager.shared
  @ObservedObject private var contentManager = MainManager.shared.contentManager
  @ObservedObject private var entryManager = MainManager.shared.entryManager


  @State private var isShowingEntrySheet = false
  @State private var isShowingBottomSheet = true
  @State private var isShowingDocSheet = false
  @State private var isShowingDocEntrySheet = false

  @State private var currentEntry: Entry?

  private var entriesSelected: [Entry] {
    get {
      Array(contentManager.selectionMap.values)
    }
  }
  @State var editViewFromDocSheet: EditView?

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
          ForEach(entryManager.idMap.sorted(by: {$0.value > $1.value}), id: \.key) { id, entry in
            EntryRow(entry: entry, action: {
              selectRow(with: entry)
              if !contentManager.isMultiSelectOn {
                currentEntry = entry
                isShowingEntrySheet.toggle()
              }
            }, secondaryAction: {
              contentManager.isMultiSelectOn.toggle()
            }, thirdAction: {
//              contentManager.isEditModeOn.toggle()
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
        mainManager.loadAll()
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
              self.editViewFromDocSheet = EditView(url: url)
              isShowingDocEntrySheet.toggle()
            }.onDisappear {
              MainManager.shared.loadAll()
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
    .environmentObject(mainManager)
    .environmentObject(entryManager)
    .environmentObject(contentManager)
  }

  func onDelete(at offsets: IndexSet) {
    // preserve all ids to be deleted to avoid indices confusing
    let idsToDelete = offsets.map { Array(entryManager.idMap.keys)[$0] }
    MainManager.shared.delete(ids: idsToDelete)
  }

  func deleteAllSelectedEntries() {
    MainManager.shared.delete(entries: entriesSelected)
  }

  func selectRow(with entry: Entry) {
    contentManager.toggleSelect(entry)
  }
  

  func selectAllRows() {
    if contentManager.selectionMap.count == entryManager.idMap.count {
      contentManager.selectionMap.removeAll()
    } else {
      contentManager.selectionMap = entryManager.idMap
    }
  }

  func unselectAllRows() {
    contentManager.selectionMap.removeAll()
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
