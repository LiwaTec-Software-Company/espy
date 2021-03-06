//
//  Model.swift
//  Model
//
//  Created by Willie Johnson on 9/5/21.
//

import Foundation

protocol Model: Identifiable, Comparable {
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
  static func equateModels<T:Model>(lhs: T, rhs: T) -> Bool{
    return lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.updatedAt == rhs.updatedAt && lhs.contents == rhs.contents
  }
  
  mutating func setUpdatedAt(_ date: Date) {
    self.updatedAt = date
  }


  func getLongStringDate() -> String {
    return createdAt.formattedStringDate()
  }
}
