//
//  Meta.swift
//  Meta
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation
import UniformTypeIdentifiers

struct Meta {
  static let start: String = ":$P"
  static let end: String = "::Y"
  static let regex: String = #"/(?<=\:\$P\n)([^]+)(?=\n\:\:Y)/gm"#
}

struct MetaTag {
  static let base: String = "  "
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
  case custom(String)

  func asAstring() -> String {
    switch self {
    case .id:
      return MetaTag.id
    case .createdAt:
      return MetaTag.createdAt
    case .updatedAt:
      return MetaTag.updatedAt
    case .group:
      return MetaTag.group
    case let .custom(name):
      return name
    }
  }
}
