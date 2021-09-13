//
//  MainManager.swift
//  MainManager
//
//  Created by Willie Johnson on 9/5/21.
//

import Foundation

class MainManager: ObservableObject, Identifiable {
  static let shared = MainManager()
  @Published var isMultiSelectOn: Bool = false
  @Published var isEditModeOn: Bool = false
  @Published var selectionMap: [UUID: Entry] = [UUID: Entry]()

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
      selectionMap.count == EntryManager.shared.idMap.count
    }
  }

  func isEntrySelected(_ entry: Entry) -> Bool {
    return selectionMap[entry.id] != nil
  }

  func toggleSelect(_ entry: Entry) {
    if selectionMap[entry.id] == nil {
      select(entry)
    } else {
      unselect(entry)
    }
  }

  func unselectAll() {
    selectionMap.removeAll()
  }

  func unselect(_ entry: Entry) {
    if let index = selectionMap.index(forKey: entry.id) {
      selectionMap.remove(at: index)
    }
  }

  func select(_ entry: Entry) {
    selectionMap[entry.id] = entry
  }
}

