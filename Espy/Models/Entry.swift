//
//  Entry.swift
//  Vybes
//
//  Created by Willie Johnson on 3/19/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SwiftUI

class Entry: Model {
  typealias T = Entry

  var id: UUID = UUID()
  var createdAt: Date = Date()
  var updatedAt: Date = Date()
  var contents: String = ""
  var file: File = File()
  var formatted: String {
    get {
      getContentsWithoutMeta()
    }
  }

  init() {
    self.contents = file.contents
  }
  
  init(file: File) {
    self.createdAt = file.createdAt
    self.updatedAt = file.updatedAt
    self.file = file
    self.contents = file.contents
    if let idFromFile = file.getIdTagUUID() {
      self.id = idFromFile
    }
  }

  init(id: UUID, date: Date, contents: String) {
    self.id = id
    self.createdAt = date
    self.contents = contents
  }

  init(id: UUID, date: String, contents: String) {
    self.id = id
    self.createdAt = Date().formattedDateFrom(date) ?? Date()
    self.contents = contents
  }

  init(date: Date, contents: String) {
    self.createdAt = date
    self.contents = contents
  }

  init(date: String, contents: String) {
    self.createdAt = Date().formattedDateFrom(date) ?? Date()
    self.contents = contents
  }

  init(entry: Entry, contents: String) {
    self.id = entry.id
    self.createdAt = entry.createdAt
    self.updatedAt = Date()
    self.contents = contents
    self.file = entry.file.withUpdated(contents: contents)
  }

}

extension Entry {
  func update(with contents: String) {
    self.contents = contents + file.formattedStringTags()
    self.file = self.file.withUpdated(contents: contents)
    self.updatedAt = Date()
  }

  func updated(with contents: String) -> Entry {
    self.update(with: contents)
    return self
  }

  func update(with file: File) {
    self.contents = file.contents
    set(file: file)
    self.updatedAt = Date()
  }

  func set(file: File) {
    self.file = file
    self.contents = file.contents
  }

  static func < (lhs: Entry, rhs: Entry) -> Bool {
    compareModels(lhs: lhs, rhs: rhs)
  }

  static func == (lhs: Entry, rhs: Entry) -> Bool {
    return lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.updatedAt == rhs.updatedAt && lhs.contents == rhs.contents && lhs.file == rhs.file
  }

  func getContentsWithoutMeta() -> String {
    return Meta.regex.replacingMatch(in: contents, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
