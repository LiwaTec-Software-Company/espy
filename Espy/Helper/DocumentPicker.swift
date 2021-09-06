//
//  DocumentPickerViewController.swift
//  Espy
//
//  Created by Willie Johnson on 8/31/21.
//

import Foundation
import SwiftUI
import MobileCoreServices

struct DocumentPicker: UIViewControllerRepresentable {
  var callback: (URL) -> ()

  func makeCoordinator() -> Coordinator {
    return Coordinator(documentController: self)
  }

  func updateUIViewController(
    _ uiViewController: UIDocumentPickerViewController,
    context: UIViewControllerRepresentableContext<DocumentPicker>) {
  }

  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let controller = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .open)
    controller.directoryURL = LocalManager.getDocumentDiretoryURL()
    controller.delegate = context.coordinator
    controller.allowsMultipleSelection = true

    return controller
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    var documentController: DocumentPicker

    init(documentController: DocumentPicker) {
      self.documentController = documentController
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
      defer { url.stopAccessingSecurityScopedResource() }
      documentController.callback(urls[0])
    }
  }
}
