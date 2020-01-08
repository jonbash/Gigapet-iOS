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

    static func userInfoKey(for userID: Int) -> String {
        return "user_\(userID)_info"
    }

    // MARK: - Segues

    static let showAuthScreenSegue = "ShowAuthScreenSegue"
    static let feedPetSegue = "FeedPetSegue"
    static let pastEntriesSegue = "PastEntriesSegue"
    static let editEntrySegue = "EditEntrySegue"

    // MARK: - TableView Cells

    static let entryCell = "EntryCell"
    static let timePeriodCell = "TimePeriodCell"

    // MARK: - Assets

    static let mainPurple = "MainPurple"

    static let funFont = "Rancho-Regular"
    static let regularFont = "HindMadurai"
}
