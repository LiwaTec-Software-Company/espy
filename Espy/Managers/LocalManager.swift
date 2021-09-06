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

class LocalManager: ObservableObject  {
  static let shared = LocalManager()
  var idMap = [UUID: File]()
  let fileManager: FileManager!
  
  init() {
    self.fileManager = FileManager.default
  }

  func loadAllLocalFiles() -> [File]? {
    var files = [File]()
    do {
      let urls = try fileManager.contentsOfDirectory(at: LocalManager.getDocumentDiretoryURL(), includingPropertiesForKeys: nil)
      for url in urls {
        if !url.lastPathComponent.contains(".md") { continue }
        let file = loadFile(url)
        idMap[file.id] = file
        files.append(file)
      }
    } catch {
      print("Unable to get entires from directory.")
      return nil
    }
    return files
  }

  // CREATE
  func create(file: File, write contents: String = "") -> File {
    do {
      try contents.write(to: file.url, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }

    idMap[file.id] = file
    return file
  }

  func createFile(name: String, write contents: String = "") -> File {
    let file = File(name: name, contents: contents)
    return create(file: file)
  }

  func getFile(with url: URL) -> File {
    for file in idMap.values {
      if file.url == url {
        return file
      }
    }
    return loadFile(url)
  }

  // READ
  func loadFile(_ url: URL, extension: String = "md") -> File {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = getContentsFrom(file: url)
    let attributes = getFileAttributes(url: url)
    let createdAt = attributes?[FileAttributeKey.creationDate] as? Date
    let updatedAt = attributes?[FileAttributeKey.modificationDate] as? Date
    return File(name: name, url: url, createdAt: createdAt, updatedAt: updatedAt, contents: contents)
  }

  func getContentsFrom(file url: URL) -> String? {
    do {
      return try String(contentsOf: url, encoding: .utf8)
    } catch {
      return nil
    }
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

  func delete(file: File) {
    do {
      try fileManager.removeItem(at: file.url)
    } catch let error as NSError {
      print("Failed deleting files : \(error)")
    }

    remove(file: file)
  }

  private func remove(file: File) {
    if let index = idMap.index(forKey: file.id) {
      idMap.remove(at: index)
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

  func getFileAttributes(url: URL) -> [FileAttributeKey: Any]? {
    do {
      return try fileManager.attributesOfItem(atPath: url.path)
    } catch {
      return nil
    }
  }

  func getFileModificationDate(url: URL) -> Date? {
    do {
      let attributes = try fileManager.attributesOfItem(atPath: url.path)
      return attributes[FileAttributeKey.modificationDate] as? Date
    } catch {
      return nil
    }
  }
}

extension LocalManager {
  static func getDocumentDiretoryURL() -> URL {
    return DocumentsDirectory.localDocumentsURL
  }

  static func asMarkdown(name: String) -> URL {
    return getDocumentDiretoryURL().appendingPathComponent("\(name).md")
  }
}
