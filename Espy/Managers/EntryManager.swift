//
//  EntryManager.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation



class EntryManager: ObservableObject  {
  static let shared = EntryManager()
  @Published var idMap = [UUID: Entry]()

  func add(_ entry: Entry) {
    idMap[entry.id] = entry
  }

  func add(_ entries: [Entry]) {
    for entry in entries {
      add(entry)
    }
  }

  func getEntry(with id: UUID) -> Entry? {
    return idMap[id]
  }

  /// Removes given entry from the idMap
  func remove(_ entry: Entry) {
    guard let index = idMap.index(forKey: entry.id) else { return }
    idMap.remove(at: index)
  }

  func removeEntry(with id: UUID) {
    guard let index = idMap.index(forKey: id) else { return }
    idMap.remove(at: index)
  }

  func remove(_ entries: [Entry]) {
    for entry in entries {
      remove(entry)
    }
  }
}

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}



