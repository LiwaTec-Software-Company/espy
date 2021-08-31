//
//  Entry.swift
//  Vybes
//
//  Created by Willie Johnson on 3/19/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct Entry: Identifiable {
  /// Unique id of the entry which is basically the date down to seconds.
  var id: UUID = UUID()
  /// The date the entry was entered.
  var date: Date = Date()
  /// Date this entry was updated by the user.
  var lastUpdated: Date = Date()
  /// The text that was entered by the user.
  var content: String = ""
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
    self.date = date
    self.lastUpdated = date
    self.content = content
  }

  init(date: String, content: String) {
    self.date = Date().formattedDateFrom(date) ?? Date()
    self.lastUpdated = self.date
    self.content = content
  }

  init(entry: Entry, content: String) {
    self.date = entry.date
    self.lastUpdated = entry.lastUpdated
    self.content = content
  }
}
