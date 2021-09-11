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
    let createdAtTag = Tag(.createdAt, createdAt.formattedStringDate())
    let updatedAtTag = Tag(.updatedAt, updatedAt.formattedStringDate())

    self.tagMap[.createdAt] = createdAtTag
    self.tagMap[.updatedAt] = updatedAtTag

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
    if tagMap != nil {
      self.tagMap = tagMap!
    }
  }

  init(name: String, contents: String?) {
    let url = LocalManager.asMarkdown(name: name)
    self.init(name: name, url: url, createdAt: nil, updatedAt: nil, tagMap: nil, contents: contents)
  }

  func extractEntryId() -> UUID? {
    guard let lastLine = contents.split(whereSeparator: \.isNewline).last else { return nil }
    return UUID(uuidString: String(lastLine))
  }

  func formattedStringTags() -> String {
    var meta: String = "\(Meta.start)\n"
    for (name, tag) in tagMap {
      meta += "\(Meta.indent)\(name.asAstring()) \(tag.value)\n"
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
}
