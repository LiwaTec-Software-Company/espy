//
//  EditViewModel.swift
//  EditViewModel
//
//  Created by Willie Johnson on 9/13/21.
//

import SwiftUI

class EditViewModel: ObservableObject, Identifiable {
  @EnvironmentObject var viewModel: MainViewModel

  @Published var selectedEntry: Entry!

  @Published var isNew: Bool = false
  @Published var isAtBottom: Bool = false
  @Published var isTextUpdated: Bool = false

  @Published var fullText: String = "# "
  @Published var currentDate: Date = Date()
  @Published var activeFont: UIFont = .systemFont(ofSize: 18, weight: .regular)

  @FocusState  var isEditingText: Bool

  private var originalText: String = ""

  var selectedID: UUID {
    get {
      self.selectedEntry.id
    }
  }

  private unowned let coordinator: MainCoordinator

  init(entry: Entry = Entry(), coordinator: MainCoordinator, isNew: Bool = false) {
    self.selectedEntry = entry
    self.coordinator = coordinator
    self.isNew = isNew
  }

  func save() {
    if isNew {
     coordinator.add(selectedEntry.updated(with: fullText))
    } else {
     coordinator.update(selectedEntry, with: fullText)
    }
//    coordinator.unselectAllRows()
  }

  func delete(_ entry: Entry) {
    coordinator.delete(entry)
  }

  func onEditorChanged() {
    isTextUpdated = fullText != originalText
    currentDate = Date()
  }
}
