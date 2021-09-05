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
  var createdAt!
  var updatedAt!
  var url: URL!
  var name: String!
  var contents: String!
  var path: String {
    url.path
  }

  init() {
    self.name = createdAt.formattedStringDate()
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
    let url = LocalManager.shared.getDocumentDiretoryURL().appendingPathComponent("\(name).md")
    self.init(name: name, url: url, createdAt: nil, updatedAt: nil, contents: contents)
  }

  func extractEntryId() -> UUID? {
    guard let lastLine = contents.split(whereSeparator: \.isNewline).last else { return nil }
    return UUID(uuidString: String(lastLine))
  }

  static func < (lhs: File, rhs: File) -> Bool {
    compareModels(lhs: lhs, rhs: rhs)
  }

}
