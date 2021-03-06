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
    createFile(for: entry)
    entryManager.add(entry)
  }

  func createFile(for entry: Entry) {
    var file = entry.file
    file.set(name: .id, to: entry.id.uuidString)

    let formattedContents = entry.getContentsWithoutMeta() + "\n\n" + file.formattedStringTags()
    let newFile = localManager.create(file: entry.file, write: formattedContents)
    entry.set(file: newFile)
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
      entries.append(loadEntry(from: file))
    }
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
    if let entryId = file.getIdTagUUID(),
       let entry = entryManager.getEntry(with: entryId) {
      return entry
    }
    return Entry(file: file)
  }

  func getEntry(with file: File) -> Entry {
    guard let entryId = file.getIdTagUUID(),
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
  func update(entry: Entry, with contents: String) {
    entryManager.update(entry, with: contents)
    localManager.update(entry.file)
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
