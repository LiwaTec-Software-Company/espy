  //
  //  EspyApp.swift
  //  Espy
  //
  //  Created by Willie Johnson on 8/29/21.
  //

import SwiftUI

@available(iOS 15.0, *)
@main
struct EspyApp: App {
  @StateObject var coordinator: Coordinator = Coordinator(manager: Manager.shared)
  var body: some Scene {
    WindowGroup {
      CoordinatorView(coordinator: coordinator)
    }
  }
}
