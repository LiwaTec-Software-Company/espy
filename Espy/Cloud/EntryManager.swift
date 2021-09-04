//
//  EntryManager.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation

typealias EntryMap = [Entry: UUID]


func ==(lhs: EntryMap, rhs: EntryMap) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

func >(lhs: EntryMap, rhs: EntryMap ) -> Bool {
  return lhs.count > rhs.count
}

func <(lhs: EntryMap, rhs: EntryMap ) -> Bool {
  return lhs.count < rhs.count
}

class EntryManager: ObservableObject  {
  static let shared = EntryManager()
  @Published var entryMap = EntryMap()

  var entries: [Entry] {
    get {
      Array(entryMap.keys)
    }
  }

  func add(_ entry: Entry) {
    entryMap[entry] = entry.id
  }

  func add(_ entries: [Entry]) {
    for entry in entries {
      add(entry)
    }
  }

  func getEntry(with id: UUID) -> Entry? {
    return entryMap.key(forValue: id)
  }

  func remove(_ entry: Entry) {
    guard let index = entryMap.index(forKey: entry) else { return }
    entryMap.remove(at: index)
  }

  func removeEntry(with id: UUID) {
    guard let entry = entryMap.key(forValue: id) else { return }
    guard let index = entryMap.index(forKey: entry) else { return }
    entryMap.remove(at: index)
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


