//
//  CloudManager.swift
//  Vybes
//
//  Created by Willie Johnson on 8/28/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

class CloudManager {
  static let shared = CloudManager()
  // Return the Document directory (Cloud OR Local)
  func isCloudEnabled() -> Bool {
    if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
    else { return false }
  }

  // Copy local files to iCloud
  // iCloud will be cleared before any operation
  // No data merging
  func copyFileToCloud() {
    if isCloudEnabled() {
      LocalManager.shared.deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
      let fileManager = FileManager.default
      let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
      while let file = enumerator?.nextObject() as? String {

        do {
          try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))

          print("Copied to iCloud")
        } catch let error as NSError {
          print("Failed to move file to Cloud : \(error)")
        }
      }
    }
  }

  // Copy iCloud files to local directory
  // Local dir will be cleared
  // No data merging
  func copyFileToLocal() {
    if isCloudEnabled() {
      LocalManager.shared.deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
      let fileManager = FileManager.default
      let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
      while let file = enumerator?.nextObject() as? String {

        do {
          try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
        } catch let error as NSError {
          print("Failed to move file to local dir : \(error)")
        }
      }
    }
  }
}
