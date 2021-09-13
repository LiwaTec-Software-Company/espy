//
//  Coordinator.swift
//  Coordinator
//
//  Created by Willie Johnson on 9/12/21.
//

import Foundation
import SwiftUI

enum Section {
  case main
  case imports
}


class Coordinator: ObservableObject {
  @Published var section: Section = .main
  @Published var mainCoordinator: MainCoordinator!
  @Published var entryCoordinator: EntryCoordinator!

  private let manager: Manager

  var entryMap: [UUID: Entry] {
    get {
      manager.getEntryMap()
    }
  }

  var selectionMap: [UUID: Entry] {
    get {
      manager.getSelectionMap()
    }
  }

  var fileMap: [UUID: File] {
    get {
      manager.getFileMap()
    }
  }

  init(manager: Manager) {
    self.manager = manager
    self.mainCoordinator = .init(manager: manager, parent: self)
    self.entryCoordinator = .init(entryManager: manager.entryManager, parent: self)
  }
}

struct CoordinatorView: View {
  @ObservedObject var coordinator: Coordinator
  var body: some View {
    MainCoordinatorView(coordinator: coordinator.mainCoordinator)
  }
}
