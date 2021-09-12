//
//  String+Extensions.swift
//  String+Extensions
//
//  Created by Willie Johnson on 9/12/21.
//

import Foundation

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
