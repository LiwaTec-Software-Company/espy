//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI

struct EntryRow: View {
  @Binding var isMultiSelectOn: Bool
  var entry: Entry
  var isSelected: Bool = false
  var action: () -> Void
  var secondaryAction: () -> Void


  var body: some View {
    Button(action: {}) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          HStack(alignment: .firstTextBaseline) {
            Text(entry.date.shortString()).font(.caption).foregroundColor(.accentColor)
            Spacer()
            Text(entry.lastUpdated.shortString())
              .font(.caption).foregroundColor(.gray)
          }
          Text(entry.content)

        }
      }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(Color.black)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: isSelected ? 4 : isMultiSelectOn ? 1 : 0)
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
  @ObservedObject private var entryManager = EntryManager.shared
  @State private var isShowingEntrySheet = false
  @State private var isShowingBottomSheet = true
  @State private var isShowingDocSheet = false
  @State private var isShowingDocEntrySheet = false

  @State var editViewFromDocSheet: EditView?
  @State var entriesSelected: [Entry] = []
  @State var isMultiSelectOn: Bool = false

  var body: some View {
    NavigationView {
      List {
        ForEachWithIndex(entryManager.entries) { (index: Int, entry: Entry) in
          EntryRow(isMultiSelectOn: $isMultiSelectOn, entry: entry, isSelected: self.entriesSelected.contains(entry), action: {
            if isMultiSelectOn {
              selectEntryRow(entry: entry)
            } else {
              isShowingEntrySheet.toggle()
            }
          }, secondaryAction: {
            self.isMultiSelectOn.toggle()
          }).sheet(isPresented: $isShowingEntrySheet) {
            EditView(index: index)
          }
        }.onDelete(perform: delete)
      }
      .onAppear {
        LocalManager.shared.loadAllEntryFiles()
        isShowingBottomSheet = true
      }
      .navigationTitle("Board")
      .toolbar {
        ToolbarItem(placement: .destructiveAction) {
          HStack{
            Button(action: {
              deleteAllSelectedEntries()
            }, label: {
              Image(systemName: "trash")
                .font(Font.system(size: isMultiSelectOn ? 25 : 15))
                .foregroundColor(isMultiSelectOn ? .red : .gray)
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
            Image(systemName: "paperplane")
          }
        }
      }
    }
  }

  func delete(at offsets: IndexSet) {
    // preserve all ids to be deleted to avoid indices confusing
    let entriesToDelete = offsets.map { entryManager.entries[$0] }
    LocalManager.shared.deleteEntryFiles(entriesToDelete)
  }

  func deleteAllSelectedEntries() {
    LocalManager.shared.deleteEntryFiles(entriesSelected)
    entriesSelected.removeAll()
  }

  func selectEntryRow(entry: Entry) {
    if self.entriesSelected.contains(entry) {
      self.entriesSelected.removeAll(where: { $0 == entry })
    }
    else {
      self.entriesSelected.append(entry)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
