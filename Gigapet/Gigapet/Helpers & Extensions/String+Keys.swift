//
//  String+Keys.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

extension String {

    // MARK: - KeychainAccess

    static let keychainKey = "com.jonbash.gigapet"
    static let currentUserIDKey = "currentUserID"

    static func tokenKey(forUserID userID: String) -> String {
        return "user_\(userID)_token"
    }

    // MARK: - Segues

    static let showAuthScreenSegue = "ShowAuthScreen"

    // MARK: - TableView Cells
}
