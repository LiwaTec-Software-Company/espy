//
//  File.swift
//  File
//
//  Created by Willie Johnson on 9/5/21.
//

import Foundation

struct File: Model {
  typealias T = File

  var id: UUID = UUID()
  var createdAt: Date = Date()
  var updatedAt: Date = Date()
  var url: URL!
  var name: String = ""
  var contents: String = ""
  var tagMap: [TagName: Tag] = [TagName: Tag]()
  var path: String {
    url.path
  }

  var placeHolderContent: String {
    get {
      return "# \(Date().formattedStringDate())\n\(formattedString(tags: Array(File.defaultTagMap.values)))"
    }
  }

  static var defaultTagMap: [TagName: Tag] {
    get {
      var defaultMap = [TagName: Tag]()
      let createdAtTag = Tag(.createdAt, Date().formattedStringDate())
      let updatedAtTag = Tag(.updatedAt, Date().formattedStringDate())

      defaultMap[.createdAt] = createdAtTag 
      defaultMap[.updatedAt] = updatedAtTag
      return defaultMap
    }
  }

  init() {
    self.name = createdAt.formattedStringDate()
    self.url = LocalManager.asMarkdown(name: self.name)
    self.tagMap = File.defaultTagMap
    self.tagMap[.id] = Tag(.id, self.id.uuidString)
    self.contents = "# \(createdAt)\n\(formattedStringTags())"
  }

  /// Initializer used for files loaded from local directory.
  init(name: String, url: URL, createdAt: Date?, updatedAt: Date?, tagMap: [TagName: Tag]?, contents: String?) {
    self.init()
    self.name = name
    self.url = url
    self.createdAt = createdAt ?? Date()
    self.updatedAt = updatedAt ?? self.createdAt
    self.contents = contents ?? "# \(self.createdAt.formattedStringDate()) "
    self.tagMap = tagMap ?? File.defaultTagMap
  }

  init(name: String, contents: String?) {
    let url = LocalManager.asMarkdown(name: name)
    self.init(name: name, url: url, createdAt: nil, updatedAt: nil, tagMap: nil, contents: contents)
  }

  func formattedStringTags() -> String {
    var meta: String = "\n\n\(Meta.start)\n"

    if let idTag = tagMap[.id] {
      meta += "\(Meta.indent)id \(idTag.value)\n"
    }
    for (name, tag) in tagMap {
      if name != TagName.id {
        meta += "\(Meta.indent)\(name.asAstring()) \(tag.value)\n"
      }
    }
    meta += "\(Meta.end)\n"
    return meta
  }

  func formattedString(tags: [Tag]) -> String {
    var meta: String = "\(Meta.start)\n"
    for tag in tags {
      meta += "\(Meta.indent)\(tag.name.asAstring()) \(tag.value)\n"
    }
    meta += "\(Meta.end)\n"
    return meta
  }

  static func < (lhs: File, rhs: File) -> Bool {
    return compareModels(lhs: lhs, rhs: rhs)
  }

  static func == (lhs: File, rhs: File) -> Bool {
    return equateModels(lhs: lhs, rhs: rhs)
  }
}

extension File {
  mutating func set(name: TagName, to value: String) {
    self.tagMap[name] = Tag(name, value)
  }

  func withUpdated(contents: String) -> File {
    return File(name: self.name,
                url: self.url,
                createdAt: self.createdAt,
                updatedAt: self.updatedAt,
                tagMap: self.tagMap,
                contents: contents)
  }

  func getIdTagUUID() -> UUID? {
    if let idTag = tagMap[.id],
       let uuid = UUID(uuidString: idTag.value) {
      return uuid
    }
    return nil
  }
}
