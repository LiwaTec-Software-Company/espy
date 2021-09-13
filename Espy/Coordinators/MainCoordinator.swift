//
//  MainCoordinator.swift
//  MainCoordinator
//
//  Created by Willie Johnson on 9/12/21.
//

import Foundation
import SwiftUI

enum Sheet {
  case entry
  case docs
  case exports
}

class MainCoordinator: ObservableObject, Identifiable {
  @Published var section: Section = .main
  @Published var viewModel: MainViewModel!
  @Published var editViewModel: EditView?
//  @Published var editViewFromDocSheet: EditView?

  @Published var isShowingEntrySheet = false
  @Published var isShowingBottomSheet = true
  @Published var isShowingDocSheet = false
  @Published var isShowingDocEntrySheet = false

  @Published var currentEntry: Entry?

  private let manager: Manager
  private unowned let parent: Coordinator


  init(manager: Manager, parent: Coordinator) {
    self.manager = manager
    self.parent = parent
    self.viewModel = .init(coordinator: self, manager: manager)
    self.loadAll()
  }

  func loadAll() {
    manager.loadAll()
  }

  func open(_ entry: Entry, isNew: Bool = false) {
    self.editViewModel = EditView(entry, isNew: isNew)
    self.currentEntry = entry
  }

  func add(_ entry: Entry, with contents: String) {
    viewModel.add(entry)
  }

  func delete(_ entry: Entry) {
    viewModel.delete(entry)
  }

  func delete(_ entries: [Entry]) {
    viewModel.delete(entries)
  }

  func unselectAllRows() {
    viewModel.unselectAll()
    currentEntry = nil
  }
}

struct MainCoordinatorView: View {
  @ObservedObject var coordinator: MainCoordinator

  var body: some View {
    MainView(viewModel: coordinator.viewModel)
      .sheet(item: $coordinator.currentEntry, content: { entry in
        EditView(entry).onDisappear(perform: coordinator.unselectAllRows)
      })
      .sheet(isPresented: $coordinator.isShowingDocSheet, content: {
        DocumentPickerView { url in
          coordinator.editViewModel = EditView(url: url)
          coordinator.isShowingDocEntrySheet.toggle()
        }.onDisappear {
          coordinator.loadAll()
        }
      })
      .environmentObject(coordinator.viewModel)
  }
}
