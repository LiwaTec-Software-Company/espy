  //
  //  Manager.swift
  //  Manager
  //
  //  Created by Willie Johnson on 9/5/21.
  //

import Foundation

struct Manager {
  static let shared = Manager()
  var cloudManager: CloudManager!
  var localManager: LocalManager!
  var entryManager: EntryManager!
  var contentManager: ContentManager!

  init() {
    cloudManager = CloudManager.shared
    localManager = LocalManager.shared
    entryManager = EntryManager.shared
    contentManager = ContentManager.shared
  }

  
}

// Mark - EntryManager
extension Manager {
    // CREATE
  func createFileFor(_ entry: Entry) {
    let file = localManager.create(file: entry.file)
    entry.file = file
    entryManager.add(entry)
    contentManager.update()
  }

  // READ
  func loadEntry(from url: URL) -> Entry {
    let file = localManager.loadFile(url)
    let entry = Entry(file: file)
    entryManager.add(entry)
    return entry
  }

  // UPDATE
  // DESTROY

}
