//
//  TimeInterval+Extensions.swift
//  Vybes
//
//  Created by Willie Johnson on 4/17/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

extension TimeInterval {
  // builds string in app's labels format 00:00
  func stringFormatted() -> String {
    let interval = Int(self)
    let seconds = interval % 60
    let minutes = (interval / 60) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
