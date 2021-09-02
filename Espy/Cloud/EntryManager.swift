//
//  EntryManager.swift
//  Espy
//
//  Created by Willie Johnson on 9/1/21.
//

import Foundation

class EntryManager: ObservableObject  {
  static let shared = EntryManager()
  @Published var entries = [Entry]()
}
