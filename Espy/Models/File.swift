//
//  File.swift
//  File
//
//  Created by Willie Johnson on 9/5/21.
//

import Foundation

struct File: Model {
  typealias T = File

  static let metaStart: String = ":$p"
  static let metaEnd: String = "::y"

  var id: UUID = UUID()
  var createdAt: Date = Date()
  var updatedAt: Date = Date()
  var url: URL!
  var name: String = ""
  var contents: String = ""
  var metaTags: [Tag: String] = [Tag: String]()
  var path: String {
    url.path
  }

  init() {
    self.name = createdAt.formattedStringDate()
    self.url = LocalManager.asMarkdown(name: self.name)
    self.metaTags = [
      .createdAt: createdAt.formattedStringDate(),
      .updatedAt: updatedAt.formattedStringDate()
    ]
  }

  /// Initializer used for files loaded from local directory.
  init(name: String, url: URL, createdAt: Date?, updatedAt: Date?, contents: String?) {
    self.name = name
    self.url = url
    if createdAt != nil { self.createdAt = createdAt! }
    if updatedAt != nil { self.updatedAt = updatedAt! }
    if contents != nil { self.contents = contents! }
  }

  init(name: String, contents: String = "") {
    let url = LocalManager.asMarkdown(name: name)
    self.init(name: name, url: url, createdAt: nil, updatedAt: nil, contents: contents)
  }

  func extractEntryId() -> UUID? {
    guard let lastLine = contents.split(whereSeparator: \.isNewline).last else { return nil }
    return UUID(uuidString: String(lastLine))
  }

  func formattedStringTags() -> String {
    var meta: String = "\(File.metaStart)\n"
    for tag in metaTags {
      meta += "*\(tag.key) \(tag.value)\n"
    }
    meta += "\(File.metaEnd)\n"
    return meta
  }

  static func < (lhs: File, rhs: File) -> Bool {
    return compareModels(lhs: lhs, rhs: rhs)
  }

  static func == (lhs: File, rhs: File) -> Bool {
    return equateModels(lhs: lhs, rhs: rhs)
  }
}
