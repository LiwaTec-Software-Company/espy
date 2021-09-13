//
//  EntryCoordinator.swift
//  EntryCoordinator
//
//  Created by Willie Johnson on 9/12/21.
//

import Foundation

class EntryCoordinator: ObservableObject, Identifiable {
  @Published var sheet: Sheet = .entry
  private let entryManager: EntryManager

  @Published var view: EditView!

  private unowned let parent: Coordinator

  init(entryManager: EntryManager, parent: Coordinator) {
    self.entryManager = entryManager
    self.parent = parent
  }
}
