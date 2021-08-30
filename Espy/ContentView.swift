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
    VStack(spacing: 50) {
      TextEditor(text: $fullText)
      Button(action: {
        presentationMode.wrappedValue.dismiss()
      }, label: {
        Label("Close", systemImage: "xmark.circle")
      })
    }
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
          Button(action: {
            showingSheet.toggle()
          }) {
            Image(systemName: "arrowtriangle.up.fill")
          }
          .sheet(isPresented: $showingSheet) {
            SheetView()
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
