//
//  EntryTableViewCell.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()

        formatter.timeZone = .autoupdatingCurrent
        formatter.calendar = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter
    }()

    weak var entry: FoodEntry? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let date = entry?.dateFed else { return }
        
        detailTextLabel?.text = EntryTableViewCell.dateFormatter.string(from: date)
        textLabel?.text = entry?.foodName
    }
}
