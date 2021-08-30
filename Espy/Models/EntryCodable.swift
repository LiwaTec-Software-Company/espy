//
//  Entry.swift
//  Vybes
//
//  Created by Willie Johnson on 3/19/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct Entry {
  /// The date the entry was entered.
  var date: Date
  /// The text that was entered by the user.
  var content: String
  /// The date formatted for use in app.
  var formattedStringDate: String {
    return date.formattedStringDate()
  }

  init(date: Date, content: String) {
    self.date = date
    self.content = content
  }

  init(date: String, content: String) {
    self.date = Date().formattedDateFrom(date) ?? Date()
    self.content = content
  }

  init(entry: Entry, content: String) {
    self = entry
    self.content = content
  }
}

struct EntryCodable: Codable {
  /// The id of the entry
  var id: Int?
  /// The date the entry was entered.
  var date: String
  /// The text that was entered by the user.
  var body: String
  /// The date when the Entry was created.
  var created_at: String?
  /// The date formatted for use in app.
  var formattedStringDate: String {
    get {
      guard let createdAt = created_at else {
        return Date().formattedStringDate()
      }
      return createdAt
    }
  }

  init(date: String, body: String) {
    self.date = date
    self.body = body
  }

  init(entry: EntryCodable, body: String) {
    self = entry
    self.body = body
  }

}
