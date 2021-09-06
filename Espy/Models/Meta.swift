//
//  Meta.swift
//  Meta
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation

enum Tag: String {
  case id = "*id"
  case createdAt = "*createdAt"
  case updatedAt = "*updatedAt"
  case group = "*group"
}

struct Meta {
  static let blockStart: String = ":$p"
  static let blockEnd: String = "::y"
}
