  //
  //  Manager.swift
  //  Manager
  //
  //  Created by Willie Johnson on 9/5/21.
  //

import Foundation

class MainManager: ObservableObject {
  static let shared = MainManager()
  var cloudManager: CloudManager!
  var localManager: LocalManager!
  var entryManager: EntryManager!
  var contentManager: ContentManager!

  var entries: [Entry] {
    get {
      Array(entryManager.idMap.values)
    }
  }

  init() {
    cloudManager = CloudManager.shared
    localManager = LocalManager.shared
    entryManager = EntryManager.shared
    contentManager = ContentManager.shared
  }
}

// Mark - EntryManager
extension MainManager {
  // CREATE
  func add(entry: Entry) {
    entryManager.add(entry)
    let _ = createFile(for: entry)
  }

  func createFile(for entry: Entry) -> File {
    return localManager.create(file: entry.file)
  }

  // READ
  func loadAll() {
    guard let files = localManager.loadAllLocalFiles() else { return }
    let _ = loadEntries(from: files)
  }

  func loadEntry(from file: File) -> Entry {
    let entry = Entry(file: file)
    entryManager.add(entry)
    return entry
  }

  func loadEntries(from files: [File]) -> [Entry] {
    var entries = [Entry]()
    for file in files {
      entries.append(Entry(file: file))
    }
    entryManager.add(entries)
    return entries
  }

  func loadEntry(from url: URL) -> Entry {
    let file = localManager.loadFile(url)
    let entry = Entry(file: file)
    entryManager.add(entry)
    return entry
  }

  func getEntry(with url: URL) -> Entry {
    let file = localManager.getFile(with: url)
    guard let entryId = file.extractEntryId(),
    let entry = entryManager.getEntry(with: entryId) else {
      return Entry(file: file)
    }
    return entry
  }

  func getEntry(with file: File) -> Entry {
    guard let entryId = file.extractEntryId(),
    let entry = entryManager.getEntry(with: entryId) else {
      return Entry(file: file)
    }
    return entry
  }


  func getEntry(with id: UUID) -> Entry? {
    return entryManager.getEntry(with: id)
  }


  func getEntries(from files: [File]) -> [Entry] {
    var entries = [Entry]()
    for file in files {
      entries.append(getEntry(with: file))
    }
    return entries
  }


  // UPDATE
  func update(entry: Entry) {

  }

  func delete(entry: Entry) {
    entryManager.remove(entry)
    localManager.delete(file: entry.file)
  }

  func delete(entries: [Entry]) {
    for entry in entries {
      delete(entry: entry)
    }
  }

  func delete(ids: [UUID]) {
    for id in ids {
      if let entry = getEntry(with: id) {
        entryManager.removeEntry(with: id)
        localManager.delete(file: entry.file)
        
      }
    }
  }
  // DESTROY
}
