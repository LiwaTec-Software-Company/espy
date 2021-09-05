//
//  Model.swift
//  Model
//
//  Created by Willie Johnson on 9/5/21.
//

import Foundation

protocol Model: Identifiable, Hashable, Comparable {
  associatedtype T
  var id: UUID { get set }
  var createdAt: Date  { get set }
  var updatedAt: Date { get set }
  var contents: String { get set }
}

extension Model {
  static func compareModels<T: Model>(lhs: T, rhs: T) -> Bool {
    return lhs.createdAt < rhs.createdAt  && lhs.updatedAt < rhs.updatedAt
  }

  mutating func setUpdatedAt(_ date: Date) {
    self.updatedAt = date
  }

  func getInSaveFormat() -> String {
      return contents + "\n\n" + id.uuidString
  }

  func getLongStringDate() -> String {
    return createdAt.formattedStringDate()
  }
}
