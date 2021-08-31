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

  @State var entry: Entry
  @State var fullText: String = ""

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      Text(entry.date.displayDate()).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).font(.title3).foregroundColor(.blue)
      Text(entry.id.uuidString).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).font(.subheadline)
      TextEditor(text: $fullText).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
      Button(action: {
        let date = Date()
        entry.content = fullText
        entry.lastUpdated = date

        cloudManager.updateEntry(entry)

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
  @State private var showingSheet = true

  var body: some View {
    NavigationView {
      List {
        ForEach(cloudManager.entries) { (entry: Entry) in
          Button(action: {
            showingSheet.toggle()
          }) {
            VStack(alignment: .leading, spacing: 2) {
              Text(entry.date.shortString()).font(.subheadline).foregroundColor(.blue)
              Text(entry.content)
            }
          }
          .sheet(isPresented: $showingSheet) {
            EditView(entry: entry, fullText: entry.content)
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
              showingSheet.toggle()
            }) {
              Image(systemName: "chevron.compact.up")
                .font(.system(size: 44.0, weight: .bold))
            }
            .sheet(isPresented: $showingSheet) {
              EditView(entry: Entry())
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
