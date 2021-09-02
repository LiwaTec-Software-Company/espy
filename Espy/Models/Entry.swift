//
//  Entry.swift
//  Vybes
//
//  Created by Willie Johnson on 3/19/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct Entry: Identifiable, Hashable {
  /// Unique id of the entry which is basically the date down to seconds.
  var id: UUID
  /// Index in CloudManager
  var index: Int = 0
  /// The date the entry was entered.
  var date: Date
  /// Date this entry was updated by the user.
  var lastUpdated: Date
  /// The text that was entered by the user.
  var content: String
  var inSaveFormat: String {
    get {
      return content + "\n\n" + id.uuidString
    }
  }
  /// The date formatted for use in app.
  var formattedStringDate: String {
    return date.formattedStringDate()
  }

  init() {
    self.id = UUID()
    self.date = Date()
    self.lastUpdated = self.date
    self.content = ""
  }

  init(id: UUID, date: Date, content: String) {
    self.id = id
    self.date = date
    self.lastUpdated = date
    self.content = content
  }

  init(id: UUID, date: String, content: String) {
    self.id = id
    self.date = Date().formattedDateFrom(date) ?? Date()
    self.lastUpdated = self.date
    self.content = content
  }

  init(date: Date, content: String) {
    self.id = UUID()
    self.date = date
    self.lastUpdated = date
    self.content = content
  }

  init(date: String, content: String) {
    self.id = UUID()
    self.date = Date().formattedDateFrom(date) ?? Date()
    self.lastUpdated = self.date
    self.content = content
  }

  init(entry: Entry, content: String) {
    self.id = entry.id
    self.date = entry.date
    self.lastUpdated = Date()
    self.content = content
  }

  mutating func setIndex(_ index: Int) {
    self.index = index
  }

  mutating func setLastUpdated(_ date: Date) {
    self.lastUpdated = date
  }
}
