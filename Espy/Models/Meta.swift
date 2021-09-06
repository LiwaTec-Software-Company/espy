//
//  Meta.swift
//  Meta
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation
import UniformTypeIdentifiers

struct Meta {
  static let blockStart: String = ":$P" // :$P
  static let blockEnd: String = "::Y" // ::Y
  static let base: String = "*"
}

struct Tags {
  static let id = "id"
  static let createdAt = "createdAt"
  static let updatedAt = "updatedAt"
  static let group = "group"
}

enum ModelTag: Hashable {
  case id
  case createdAt
  case updatedAt
  case group
  case custom(name: String)

  func asAstring() -> String {
    switch self {
    case .id:
      return Tags.id
    case .createdAt:
      return Tags.createdAt
    case .updatedAt:
      return Tags.updatedAt
    case .group:
      return Tags.group
    case .custom(let name):
      return name
    }
  }
}
