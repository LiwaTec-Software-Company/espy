//
//  User.swift
//  Vybes
//
//  Created by Willie Johnson on 3/25/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

/// The User model used to encode and decode user data
struct User: Codable {
  /// The name of the user used as a username.
  var name: String
  /// The email of the user used for login.
  var email: String
  /// The token used for user authentication.
  var token: String
}
