//
//  LocalManager.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation

struct DocumentsDirectory {
  static let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
}


class LocalManager {
  static let shared = LocalManager()

  var entryFiles: [UUID: String] = [UUID: String]()
  let fileManager: FileManager!
  
  init() {
    self.fileManager = FileManager.default
    self.loadAllEntryFiles()
  }

  func getDocumentDiretoryURL() -> URL {
//    if CloudManager.shared.isCloudEnabled()  {
//      return DocumentsDirectory.iCloudDocumentsURL!
//    } else {
//      return DocumentsDirectory.localDocumentsURL
//    }
    return DocumentsDirectory.localDocumentsURL
  }

  func doesFileExist(_ url: URL) -> Bool {
    return fileManager.fileExists(atPath: url.path)
  }

  func doesFileExist(_ filePath: String) -> Bool {
    return fileManager.fileExists(atPath: filePath)
  }

  func deleteFilesInDirectory(url: URL?) {
    let enumerator = fileManager.enumerator(atPath: url!.path)
    while let file = enumerator?.nextObject() as? String {
      do {
        try fileManager.removeItem(at: url!.appendingPathComponent(file))
        print("Files deleted")
      } catch let error as NSError {
        print("Failed deleting files : \(error)")
      }
    }
  }

  func deleteFile(url: URL) {
    do {
      try fileManager.removeItem(at: url)
    } catch let error as NSError {
      print("Failed deleting files : \(error)")
    }
  }

  func deleteFile(filePath: String) {
    do {
      try fileManager.removeItem(atPath: filePath)
    } catch let error as NSError {
      print("Failed deleting files : \(error)")
    }
  }

  func getFileModificationDate(url: URL) -> Date? {
      do {
          let attr = try fileManager.attributesOfItem(atPath: url.path)
          return attr[FileAttributeKey.modificationDate] as? Date
      } catch {
          return nil
      }
  }
}

// MARK - EntryManager
extension LocalManager {
  // CREATE
  func createFileFor(_ entry: Entry) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")

    do {
      try entry.inSaveFormat.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }

    entryFiles[entry.id] = fileURL.path
    EntryManager.shared.add(entry)
  }

  // READ
  func getLocalEntry(with file: URL) -> Entry? {
    for (entryId, entryFilePath) in entryFiles {
      if entryFilePath == file.path {
        return EntryManager.shared.getEntry(with: entryId)
      }
    }
    
    return nil
  }
  
  func getLocalEntry(with filePath: String) -> Entry? {
    for (entryId, entryFilePath) in entryFiles {
      if entryFilePath == filePath {
        return EntryManager.shared.getEntry(with: entryId)
      }
    }
    return nil
  }

  func getEntry(from file: URL) -> Entry? {
    if let entry = getLocalEntry(with: file) {
      return entry
    }

    if !file.lastPathComponent.contains(".md") { return  nil }
    let fileName = file.deletingPathExtension().lastPathComponent
    let lastUpdated = getFileModificationDate(url: file)

    do {
      let content = try String(contentsOf: file, encoding: .utf8)
      var lines = content.components(separatedBy: .newlines)

      guard let lastLine = lines.last, let entryId = UUID(uuidString: lastLine) else {
        var entry = Entry(date: fileName, content: content)
        if let lastUpdated = lastUpdated {
          entry.setLastUpdated(lastUpdated)
        }
        return entry
      }
      lines.removeLast()
      let entryContent = lines.joined(separator: "\n")
      var entry = Entry(id: entryId, date: fileName, content: entryContent)
      if let lastUpdated = lastUpdated {
        entry.setLastUpdated(lastUpdated)
      }
      return entry
    } catch {
      print("Cant open this particulate file :/", file)
      return nil
    }
  }

  // UPDATE
  func loadAllEntryFiles() {
    var entries = [Entry]()
    do {
      let files = try FileManager.default.contentsOfDirectory(at: getDocumentDiretoryURL(), includingPropertiesForKeys: nil)

      for file in files {
        if !file.lastPathComponent.contains(".md") { continue }
        guard let entry = getEntry(from: file) else { continue }
        entryFiles[entry.id] = file.path
        entries.append(entry)
      }
    } catch {
      print("Unable to get entires from directory.")
    }
    EntryManager.shared.add(entries)
  }

  func updateEntryAndFile(with id: UUID) {
    guard let entry = EntryManager.shared.getEntry(with: id) else { return }
    guard let entryFilePath = entryFiles[id] else { return }

    if doesFileExist(entryFilePath) {
      deleteFile(filePath: entryFilePath)
      deleteEntryAndFile(with: id)
    }

    createFileFor(entry)
  }

  // DESTROY
  func deleteEntryAndFile(_ entry: Entry) {
    deleteEntryAndFile(with: entry.id)
  }

  func deleteEntryAndFile(with id: UUID) {
    guard let idIndex = entryFiles.index(forKey: id) else { return }
    let toDelete = entryFiles.remove(at: idIndex)
    EntryManager.shared.removeEntry(with: id)
    deleteFile(filePath: toDelete.value)
  }

  func deleteEntriesAndFiles(_ entries: [Entry]) {
    for entry in entries {
      self.deleteEntryAndFile(entry)
    }
  }
}
