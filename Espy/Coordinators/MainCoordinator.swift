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
  @Published var editViewModel: EditViewModel?

  @Published var isShowingEntrySheet = false
  @Published var isShowingBottomSheet = true
  @Published var isShowingDocSheet = false
  @Published var isShowingDocEntrySheet = false

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
    self.editViewModel = .init(entry: entry, coordinator: self, isNew: isNew)
  }

  func open(url: URL) {
    let entryFromURL = Manager.shared.getEntry(with: url)
    self.editViewModel = .init(entry: entryFromURL, coordinator: self, isNew: false)
  }

  func add(_ entry: Entry) {
    viewModel.add(entry)
  }

  func update(_ entry: Entry, with contents: String) {
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
    editViewModel = nil
  }
}

struct MainCoordinatorView: View {
  @ObservedObject var coordinator: MainCoordinator

  var body: some View {
    MainView(viewModel: coordinator.viewModel)
      .sheet(item: $coordinator.editViewModel, content: { editViewModel in
        EditView(viewModel: editViewModel).onDisappear(perform: coordinator.unselectAllRows)
      })
      .sheet(isPresented: $coordinator.isShowingDocSheet, content: {
        DocumentPickerView { url in
          coordinator.open(url: url)
        }.onDisappear {
          coordinator.loadAll()
        }
      })
      .environmentObject(coordinator.viewModel)
  }
}
