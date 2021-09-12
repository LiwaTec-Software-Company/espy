//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
  @StateObject private var mainManager: MainManager = MainManager.shared
  @StateObject private var contentManager = MainManager.shared.contentManager
  @StateObject private var entryManager = MainManager.shared.entryManager

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
//    let barBackgroundImage = UIImage(color: UIColor(hue: 0, saturation: 1, brightness: 0, alpha: 0.7))
//    UINavigationBar.appearance().barTintColor = .clear
//    UINavigationBar.appearance().setBackgroundImage(barBackgroundImage, for: .default)
//    UIToolbar.appearance().barTintColor = .clear
//    UIToolbar.appearance().setBackgroundImage(barBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
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
        ToolbarItem(placement: .navigationBarLeading) {
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

        ToolbarItem(placement: .navigationBarTrailing) {
          EditModeButton()
        }

        ToolbarItemGroup(placement: .bottomBar) {
          ImportButton(onPress: {
            isShowingDocSheet.toggle()
          }).sheet(isPresented: $isShowingDocSheet, content: {
            DocumentPickerView { url in
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
              if contentManager.isMultipleSelected {
                ZStack {
                  Image(systemName: "chevron.compact.up")
                    .font(.system(size: 44))
                  Image(systemName: "chevron.compact.up")
                    .font(.system(size: 44)).offset(x: 0, y: 10)
                }
              } else if contentManager.isAnythingSelected {
                Image(systemName: "chevron.compact.up")
                  .font(.system(size: 44, weight: .bold))
              } else {
                Image(systemName: "chevron.compact.up")
                  .font(.system(size: 44, weight: .bold)).foregroundColor(.green)
              }

            }
            .sheet(isPresented: $isShowingBottomSheet) {
              EditView().onDisappear {
                unselectAllRows()
              }
            }
            Text("")
          }
          Spacer()
          ExportButton()
        }
      }
      VStack {
        Button("press me to open something cool") {
          isShowingDocSheet.toggle()
        }
        Button("press me to open something cool") {
          isShowingDocSheet.toggle()
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

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}



