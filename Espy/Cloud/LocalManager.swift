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

  var entryFiles: [Entry: String] = [Entry: String]()
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
  func createFileFor(_ entry: Entry, at index: Int = 0) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")

    do {
      try entry.inSaveFormat.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }

    entryFiles[entry] = fileURL.path
    EntryManager.shared.entries.insert(entry, at: index)
  }

  // READ
  func getLocalEntry(with file: URL) -> Entry? {
    for (entry, entryFilePath) in entryFiles {
      if entryFilePath == file.path {
        return entry
      }
    }
    
    return nil
  }
  
  func getLocalEntry(with filePath: String) -> Entry? {
    for (entry, entryFilePath) in entryFiles {
      if entryFilePath == filePath {
        return entry
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

      for (index, file) in files.enumerated() {
        if !file.lastPathComponent.contains(".md") { continue }
        guard var entry = getEntry(from: file) else { continue }
        entry.setIndex(index)
        entryFiles[entry] = file.path
        entries.append(entry)
      }
    } catch {
      print("Unable to get entires from directory.")
    }
    EntryManager.shared.entries = entries
  }

  func updateEntryFile(_ oldEntry: Entry,  new entry: Entry, at index: Int) {
    guard let entryFilePath = entryFiles[oldEntry] else { return }

    if doesFileExist(entryFilePath) {
      deleteFile(filePath: entryFilePath)
      deleteEntryFile(oldEntry)
      EntryManager.shared.entries.remove(at: index)
    }

    createFileFor(entry)
  }

  // DESTROY
  func deleteEntryFile(_ entry: Entry) {
    guard let entryIndex = entryFiles.index(forKey: entry) else { return }
    let deleteMe = entryFiles.remove(at: entryIndex)
    EntryManager.shared.removeEntry(entry)
    deleteFile(filePath: deleteMe.value)
  }

  func deleteEntryFiles(_ entries: [Entry]) {
    for entry in entries {
      self.deleteEntryFile(entry)
    }
  }
}
