//
//  Meta.swift
//  Meta
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation
import UniformTypeIdentifiers

protocol Tagable: Hashable {
  var name: TagName { get set }
  var value: String { get set }
  init(_ name: TagName, _ value: String)
}

struct Meta {
  static let start: String = ":SP"
  static let end: String = "::Y"
  static let regex: String = ":SP\\n[^$]+\\n::Y"
  static let indent: String = "  "
}

struct Tag: Tagable {
  var name: TagName
  var value: String
  init(_ name: TagName, _ value: String) {
    self.name = name
    self.value = value
  }
}

enum TagName: Hashable {
  case id
  case createdAt
  case updatedAt
  case group
  case custom(String)

  func asAstring() -> String {
    switch self {
    case .id:
      return "id"
    case .createdAt:
      return "createdAt"
    case .updatedAt:
      return "updatedAt"
    case .group:
      return "group"
    case let .custom(name):
      return name
    }
  }
}
