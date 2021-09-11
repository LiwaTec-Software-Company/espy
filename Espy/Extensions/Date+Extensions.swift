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
    dateFormatter.dateFormat = "yyyy-MMdd-HHmm-ss's'SSS"
    return dateFormatter.string(from: self)
  }

  func formattedDateFrom(_ text: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MMdd-HHmm-ss's'SSS"
    return dateFormatter.date(from: text)
  }

  func displayDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE MMM d yyyy | h:mm:ss a"
    return dateFormatter.string(from: self)
  }

  func shortString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE dd MMM HH:mm:ss"
    return dateFormatter.string(from: self)
  }
}
