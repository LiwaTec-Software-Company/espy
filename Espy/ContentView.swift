//
//  ContentView.swift
//  Espy
//
//  Created by Willie Johnson on 8/29/21.
//

import SwiftUI

struct SheetView: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var fullText = "Mhm..."

  
  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
      TextEditor(text: $fullText)
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
  
  var body: some View {
    NavigationView {
      List {
        Button("Show Sheet") {
          showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
          SheetView()
        }

        Button("Show Sheet") {
          showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
          SheetView()
        }

        Button("Show Sheet") {
          showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
          SheetView()
        }
      }.toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button("Press Me") {
            print("Pressed")
          }
        }
      }.padding()
      .navigationTitle("Espy")
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
              SheetView()
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
