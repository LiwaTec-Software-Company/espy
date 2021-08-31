//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI

struct EditView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var cloudManager: CloudManager

  @State var fullText: String = ""

  var selectedIndex: Int = 0
  var selectedEntry: Entry = Entry()
  var subheadlineText = ""

  var isNew = true

  init() {}

  init(index: Int, cloudManager: CloudManager, isNew: Bool = false) {
    self.selectedIndex = index
    self.selectedEntry = cloudManager.entries[selectedIndex]

    self.isNew = isNew
    _fullText = State(initialValue: selectedEntry.content)
  }

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      Text(selectedEntry.date.displayDate()).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).font(.title3).foregroundColor(.white)
      Text(selectedEntry.id.uuidString).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).font(.subheadline).foregroundColor(isNew ? .green : .blue)
      TextEditor(text: $fullText).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
      Button(action: {
        let entry = Entry(entry: selectedEntry, content: fullText)

        if isNew {
          cloudManager.addNewEntry(entry)
        } else {
          cloudManager.updateEntry(entry, at: selectedIndex)
        }

        presentationMode.wrappedValue.dismiss()
      }, label: {
        Image(systemName: "chevron.compact.down")
          .font(.system(size: 44.0, weight: .bold))
      })
    })
  }
}

struct ContentView: View {
  @StateObject var cloudManager = CloudManager()
  @State private var isShowingEntrySheet = false
  @State private var isShowingBottomSheet = true

  var body: some View {
    NavigationView {
      List {
        ForEachWithIndex(cloudManager.entries) { (index: Int, entry: Entry) in
          Button(action: {
            isShowingEntrySheet.toggle()
          }) {
            VStack(alignment: .leading, spacing: 2) {
              Text(entry.date.shortString()).font(.subheadline).foregroundColor(.blue)
              Text(entry.content)
            }
          }
          .sheet(isPresented: $isShowingEntrySheet) {
            EditView(index: index, cloudManager: cloudManager)
          }
        }.onDelete(perform: delete)
      }
      .onAppear {
        cloudManager.updateData()
      }
      .padding()
      .navigationTitle("Board")
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          Button(action: {
            print("Edit button was tapped")
          }) {
            Image(systemName: "gearshape")
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
    .environmentObject(cloudManager)
  }

  func delete(at offsets: IndexSet) {
    // preserve all ids to be deleted to avoid indices confusing
    let idsToDelete = offsets.map { self.cloudManager.entries[$0].id }
    cloudManager.deleteEntries(ids: idsToDelete)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
