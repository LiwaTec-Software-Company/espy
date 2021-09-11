//
//  NSRegularExpression+Extensions.swift
//  NSRegularExpression+Extensions
//
//  Created by Willie Johnson on 9/6/21.
//

import Foundation

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Fix this pattern: \(pattern).")
        }
    }

  func doesMatch(_ string: String) -> Bool {
    let range = NSRange(location: 0, length: string.utf16.count)
    return firstMatch(in: string, options: [], range: range) != nil
  }

  func getMatch(_ string: String) -> NSTextCheckingResult? {
    let range = NSRange(location: 0, length: string.utf16.count)
    return firstMatch(in: string, options: [], range: range)
  }

  func replacingMatch(in string: String, with template: String = "") -> String {
    let range = NSRange(location: 0, length: string.utf16.count)
    return stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
  }

  func getMatchRange(in string: String) -> Range<String.Index>? {
    guard let nsRange = getMatch(string)?.range else { return nil }
    return Range(nsRange, in: string)
  }

  func getMatches(_ string: String) -> [NSTextCheckingResult] {
    let range = NSRange(location: 0, length: string.utf16.count)
    return matches(in: string, options: [], range: range)
  }
}
