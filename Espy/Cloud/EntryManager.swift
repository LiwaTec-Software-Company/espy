//
//  EntryManager.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation

class EntryManager: ObservableObject  {
  static let shared = EntryManager()
  @Published var entries = [Entry]()

  func removeEntry(_ entry: Entry) {
    guard let index = entries.firstIndex(of: entry) else { return }
    entries.remove(at: index)
  }

  func removeEntries(_ entries: [Entry]) {
    for entry in entries {
      removeEntry(entry)
    }
  }
}
