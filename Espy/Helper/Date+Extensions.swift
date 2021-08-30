//
//  Date+Extensions.swift
//  Vybes
//
//  Created by Willie Johnson on 4/17/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

extension Date {
  func formattedStringDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
    return dateFormatter.string(from: self)
  }

  func formattedDateFrom(_ text: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
    return dateFormatter.date(from: text)
  }

  func displayDate() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm:ss a, EEE MM d yyyy"
    return dateFormatter.string(from: self)
  }
}
