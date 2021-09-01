//
//  CloudManager.swift
//  Vybes
//
//  Created by Willie Johnson on 8/28/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

struct DocumentsDirectory {
  static let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
}


class LocalManager {
  static let shared = LocalManager()
  var entryFiles: [Entry: String] = [Entry: String]()

  func deleteEntry(_ entry: Entry) {
    guard let entryIndex = entryFiles.index(forKey: entry) else { return }
    entryFiles.remove(at: entryIndex)
  }

  func getDocumentDiretoryURL() -> URL {
      return DocumentsDirectory.localDocumentsURL
  }

  func getEntry(from file: URL) -> Entry? {
    for (entry, entryFilePath) in entryFiles {
      if entryFilePath == file.path {
        return entry
      }
    }
    return nil
  }

  func getEntry(from filePath: String) -> Entry? {
    for (entry, entryFilePath) in entryFiles {
      if entryFilePath == filePath {
        return entry
      }
    }
    return nil
  }
}

class CloudManager: ObservableObject {
  @Published var entries = [Entry]()

  init() {
    updateData()
  }

  // Return the Document directory (Cloud OR Local)
  // To do in a background thread

  func getDocumentDiretoryURL() -> URL {
    if isCloudEnabled()  {
      return DocumentsDirectory.iCloudDocumentsURL!
    } else {
      return DocumentsDirectory.localDocumentsURL
    }
  }

  func doesFileExist(_ url: URL) -> Bool {
    return FileManager.default.fileExists(atPath: url.path)
  }

  func doesFileExist(_ filePath: String) -> Bool {
    return FileManager.default.fileExists(atPath: filePath)
  }

  // Return true if iCloud is enabled

  func isCloudEnabled() -> Bool {
    if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
    else { return false }
  }

  // Delete All files at URL

  func deleteFilesInDirectory(url: URL?) {
    let fileManager = FileManager.default
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
    let fileManager = FileManager.default

    do {
      try fileManager.removeItem(at: url)
    } catch let error as NSError {
      print("Failed deleting files : \(error)")
    }
  }

  func deleteFile(filePath: String) {
    let fileManager = FileManager.default

    do {
      try fileManager.removeItem(atPath: filePath)
    } catch let error as NSError {
      print("Failed deleting files : \(error)")
    }
  }

  // Copy local files to iCloud
  // iCloud will be cleared before any operation
  // No data merging

  func copyFileToCloud() {
    if isCloudEnabled() {
      deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
      let fileManager = FileManager.default
      let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
      while let file = enumerator?.nextObject() as? String {

        do {
          try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))

          print("Copied to iCloud")
        } catch let error as NSError {
          print("Failed to move file to Cloud : \(error)")
        }
      }
    }
  }

  // Copy iCloud files to local directory
  // Local dir will be cleared
  // No data merging

  func copyFileToLocal() {
    if isCloudEnabled() {
      deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
      let fileManager = FileManager.default
      let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
      while let file = enumerator?.nextObject() as? String {

        do {
          try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
        } catch let error as NSError {
          print("Failed to move file to local dir : \(error)")
        }
      }
    }
  }
}

// MARK - Entry
extension CloudManager {
  public func updateData() {
    entries = getEntries()
  }

  func getEntryIndex(entry: Entry) {

  }

  func getEntry(from file: URL) -> Entry? {
    if let entry = LocalManager.shared.getEntry(from: file) {
      return entry
    }

    if !file.lastPathComponent.contains(".md") { return  nil }
    let fileName = file.deletingPathExtension().lastPathComponent

    do {
      let content = try String(contentsOf: file, encoding: .utf8)
      var lines = content.components(separatedBy: .newlines)

      guard let lastLine = lines.last, let entryId = UUID(uuidString: lastLine) else {
        let entry = Entry(date: fileName, content: content)
        LocalManager.shared.entryFiles[entry] = file.path
        return entry
      }
      lines.removeLast()
      let entryContent = lines.joined(separator: "\n")
      let entry = Entry(id: entryId, date: fileName, content: entryContent)
      LocalManager.shared.entryFiles[entry] = file.path
      return entry
    } catch {
      print("Cant open this particulate file :/", file)
      return nil
    }
  }

  func addNewEntry(_ entry: Entry) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")
    LocalManager.shared.entryFiles[entry] = fileURL.path

    do {
      try entry.inSaveFormat.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }

    entries.insert(entry, at: 0)
  }

  func updateEntry(_ oldEntry: Entry,  new entry: Entry, at index: Int) {
    guard let entryFilePath = LocalManager.shared.entryFiles[oldEntry] else { return }

    if doesFileExist(entryFilePath) {
      deleteFile(filePath: entryFilePath)
      LocalManager.shared.deleteEntry(oldEntry)
    }

    entries.remove(at: index)
    addNewEntry(entry)
  }

  private func getEntries() -> [Entry] {
    var entries = [Entry]()
    do {
      let files = try FileManager.default.contentsOfDirectory(at: getDocumentDiretoryURL(), includingPropertiesForKeys: nil)

      for (index, file) in files.enumerated() {
        if !file.lastPathComponent.contains(".md") { continue }
        guard var entry = getEntry(from: file) else { continue }
        entry.setIndex(index)
        entries.append(entry)
        LocalManager.shared.entryFiles[entry] = file.path
      }
    } catch {
      print("Unable to get entires from directory.")
    }
    return entries
  }

  func deleteEntry(_ entry: Entry) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")
    deleteFile(url: fileURL)
    LocalManager.shared.deleteEntry(entry)
  }

  func deleteEntries(ids: [UUID]) {
    // schedule remote delete for selected ids
    _ = ids.compactMap { id in
      entries.removeAll {
        if $0.id == id {
          deleteEntry($0)
        }
        return $0.id == id
      }
    }
  }
}
