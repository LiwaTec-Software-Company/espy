  //
  //  MainViewModel.swift
  //  MainViewModel
  //
  //  Created by Willie Johnson on 9/12/21.
  //

import Foundation

class MainViewModel: ObservableObject {
  @Published var entryMap = [UUID: Entry]()
  @Published var selectionMap = [UUID: Entry]()

  @Published var isMultiSelectOn: Bool = false
  @Published var isEditModeOn: Bool = false

  var isAnythingSelected: Bool {
    get {
      selectionMap.count > 0
    }
  }

  var isMultipleSelected: Bool {
    get {
      selectionMap.count > 1
    }
  }

  var isEverythingSelected: Bool {
    get {
      selectionMap.count == entryMap.count
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
    select(entry)
    self.coordinator.open(entry, isNew: isNew)
  }

  func openDocSheet() {
    coordinator.isShowingDocSheet.toggle()
  }

  func select(_ entry: Entry) {
    selectionMap[entry.id] = entry
  }

  func add(_ entry: Entry) {
    manager.add(entry: entry)
    reloadEntryMap()
  }

  func update(_ entry: Entry, with contents: String) {
    manager.update(entry: entry, with: contents)
    reloadEntryMap()
  }

  func isEntrySelected(_ entry: Entry) -> Bool {
    return selectionMap[entry.id] != nil
  }

  func toggleSelect(_ entry: Entry) {
    if isEntrySelected(entry) {
      unselect(entry)
    } else {
      select(entry)
    }
  }

  func toggleBlockMode() {
    if isEverythingSelected && isMultiSelectOn {
      isMultiSelectOn.toggle()
      unselectAll()
    } else if isMultiSelectOn {
      selectAll()
    } else {
      isMultiSelectOn.toggle()
    }
  }
  
  func selectAll() {
    selectionMap = entryMap
  }

  func unselectAll() {
    selectionMap.removeAll()
  }

  func unselect(_ entry: Entry) {
    if let index = selectionMap.index(forKey: entry.id) {
      selectionMap.remove(at: index)
    }
  }

  func reloadEntryMap() {
    self.entryMap = manager.getEntryMap()
  }

  func deleteAllSelected() {
    manager.delete(entries: Array(selectionMap.values))
    reloadEntryMap()
  }

  func delete(_ entry: Entry) {
    manager.delete(entry: entry)
    reloadEntryMap()
  }

  func delete(_ entries: [Entry]) {
    coordinator.delete(entries)
    reloadEntryMap()
  }
}
