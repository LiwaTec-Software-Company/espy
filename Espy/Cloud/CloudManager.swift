//
//  CloudManager.swift
//  Vybes
//
//  Created by Willie Johnson on 8/28/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation



class CloudManager {
  static let instance = CloudManager()

  struct DocumentsDirectory {
    static let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
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
  func addNewEntry(_ entry: Entry) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")

    do {
      try entry.content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }
  }

  func updateEntry(_ entry: Entry) {
    let entryFile = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")
    if doesFileExist(entryFile) {
      deleteFile(url: entryFile)
    }
    do {
      try entry.content.write(to: entryFile, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to update this entry.")
    }
  }

  func getEntries() -> [Entry] {
    var entries = [Entry]()
    do {
      let files = try FileManager.default.contentsOfDirectory(at: getDocumentDiretoryURL(), includingPropertiesForKeys: nil)
      let fileNames = files.map{ $0.deletingPathExtension().lastPathComponent }

      for (index, file) in files.enumerated() {
        if !file.lastPathComponent.contains(".md") { continue }
        do {
          let content = try String(contentsOf: file, encoding: .utf8)

          let entry = Entry(date: "\(fileNames[index])", content: content)
          entries.append(entry)
        } catch {
          print("Cant open this particulate file :/", file)
        }
      }
    } catch {
      print("Unable to get entires from directory.")
    }
    return entries
  }

  func deleteEntry(_ entry: Entry) {
    let fileURL = getDocumentDiretoryURL().appendingPathComponent("\(entry.formattedStringDate).md")
    deleteFile(url: fileURL)
  }
}
