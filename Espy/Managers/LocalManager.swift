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
    let _ = self.loadAllLocalFiles()
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
  func create(file: File, write contents: String?) -> File {
    let contentsToWrite = contents ?? file.contents
    do {
      try contentsToWrite.write(to: file.url, atomically: true, encoding: .utf8)
    }
    catch {
      print("Unable to add this entry.")
    }
    let newFile = file.withUpdated(contents: contentsToWrite)
    idMap[newFile.id] = newFile
    return newFile
  }

  func createFile(name: String, write contents: String?) -> File {
    let file = File(name: name, contents: contents)
    return create(file: file, write: nil)
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
    let attributes = getFileAttributes(url: url)
    let createdAt = attributes?[FileAttributeKey.creationDate] as? Date
    let updatedAt = attributes?[FileAttributeKey.modificationDate] as? Date
    let contents = getContentsFrom(file: url)
    let metaTagMap = getTags(from: contents ?? "")

    return File(name: name, url: url, createdAt: createdAt, updatedAt: updatedAt, tagMap: metaTagMap, contents: contents)
  }

  func getTags(from contents: String) -> [TagName: Tag] {
    var tagMap = [TagName: Tag]()
    guard let metaBlockRange = Meta.regex.getMatchRange(in: contents) else {
      return tagMap
    }
    let metaTags = contents[metaBlockRange].split(whereSeparator: \.isNewline)
    for tag in metaTags {
      let sections = tag.split(whereSeparator: \.isWhitespace)
      if sections[0] == Meta.start || sections[0] == Meta.end {
        continue
      }
      let name = TagName(String(sections[0]))
      tagMap[name] = Tag(name, String(sections[1...].joined(separator: " ")))
    }
    print(tagMap)
    return tagMap
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

  func update(_ file: File, canCreateNew: Bool = true) {
    if doesFileExist(file.url) {
      delete(file: file)
      let _ = create(file: file, write: file.contents)
    }
    if canCreateNew {
      let _ = create(file: file, write: file.contents)
    }
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

