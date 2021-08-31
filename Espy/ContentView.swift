//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI

struct EditView: View {
  @Environment(\.presentationMode) var presentationMode
  
  @State private var fullText = "Mhm..."

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      Text(Date().displayDate()).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).font(.title3).foregroundColor(.blue)
      TextEditor(text: $fullText).padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
      Button(action: {
        presentationMode.wrappedValue.dismiss()
      }, label: {
        Image(systemName: "chevron.compact.down")
          .font(.system(size: 44.0, weight: .bold))
      })
    })
  }
}

struct ContentView: View {
  @State private var showingSheet = true

  let entries: [String] = ["I like pie", "Not today buddy", "Sometimes I like cakes too"]
  
  var body: some View {
    NavigationView {
      List {
        ForEach(entries, id: \.self) { entry in
          Button(action: {
            showingSheet.toggle()
          }) {
            VStack(alignment: .leading, spacing: 2) {
              Text(Date().shortString()).font(.subheadline).foregroundColor(.blue)
              Text(entry)
              Text("Some detail goes herer.")
            }
          }
          .sheet(isPresented: $showingSheet) {
            EditView()
          }
        }
      }.toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button("Press Me") {
            print("Pressed")
          }
        }
      }.padding()
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
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
