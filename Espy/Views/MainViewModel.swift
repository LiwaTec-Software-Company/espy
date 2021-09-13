  //
  //  MainViewModel.swift
  //  MainViewModel
  //
  //  Created by Willie Johnson on 9/12/21.
  //

import Foundation

class MainViewModel: ObservableObject {
  @Published var entryMap = [UUID: Entry]()
  @Published var selectionStack = [Entry]()

  @Published var isMultiSelectOn: Bool = false
  @Published var isEditModeOn: Bool = false

  var isAnythingSelected: Bool {
    get {
      selectionStack.count > 0
    }
  }

  var isMultipleSelected: Bool {
    get {
      selectionStack.count > 1
    }
  }

  var isEverythingSelected: Bool {
    get {
      selectionStack.count == entryMap.count
    }
  }

  private let manager: Manager
  private unowned let coordinator: MainCoordinator

  init(coordinator: MainCoordinator, manager: Manager) {
    self.coordinator = coordinator
    self.manager = manager
    reloadEntryMap()
  }

  func open(_ entry: Entry, isNew: Bool = false) {
    self.coordinator.open(entry, isNew: isNew)
    select(entry)
  }

  func openDocSheet() {
    coordinator.isShowingDocSheet.toggle()
  }

  func select(_ entry: Entry) {
    selectionStack.append(entry)
  }

  func add(_ entry: Entry) {
    manager.add(entry: entry)
  }

  func update(_ entry: Entry, with contents: String) {
    manager.update(entry: entry, with: contents)
  }

  func isEntrySelected(_ entry: Entry) -> Bool {
    return selectionStack.contains(entry)
  }

  func toggleSelect(_ entry: Entry) {
    if isEntrySelected(entry) {
      unselect(entry)
    } else {
      select(entry)
    }
  }
  
  func selectAll() {
    selectionStack = Array(entryMap.values)
  }

  func unselectAll() {
    selectionStack.removeAll()
  }

  func unselect(_ entry: Entry) {
    selectionStack.removeAll { selectedEntry in
      entry == selectedEntry
    }
  }

  func reloadEntryMap() {
    self.entryMap = manager.getEntryMap()
  }

  func delete(_ entry: Entry) {
    coordinator.delete(entry)
  }

  func delete(_ entries: [Entry]) {
    coordinator.delete(entries)
  }
}
