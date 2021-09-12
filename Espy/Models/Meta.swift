//
//  Meta.swift
//  Meta
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation
import UniformTypeIdentifiers

struct Tag: Identifiable {
  var id: UUID = UUID()
  var name: TagName
  var value: String

  init(_ name: TagName, _ value: String) {
    self.name = name
    self.value = value
  }
}


struct Meta {
  static let start: String = ":SP"
  static let end: String = "::Y"
  static let regexString: String = ":SP\\n[^$]+\\n::Y"
  static let regex: NSRegularExpression = NSRegularExpression(Meta.regexString)
  static let indent: String = ""
}

enum TagName: Hashable {
  case id
  case createdAt
  case updatedAt
  case group
  case defined(String)

  init(_ name: String) {
    switch name {
    case "id":
      self = .id
    case "createdAt":
      self = .createdAt
    case "updatedAt":
      self = .updatedAt
    case "group":
      self = .group
    default:
      self = .defined(name)
    }
  }

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
    case let .defined(name):
      return clean(name)
    }
  }

  func clean(_ dirtyName: String) -> String {
    return dirtyName
      .replacingOccurrences(of: "defined", with: "")
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
      .replacingOccurrences(of: "\"", with: "")
      .replacingOccurrences(of: "\\", with: "")
  }
}
