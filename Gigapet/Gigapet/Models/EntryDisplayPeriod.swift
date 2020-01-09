//
//  EntryDisplayPeriod.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct EntryDisplayPeriod {
    let type: EntryDisplayType
    var entries: [FoodEntry]
    let startDate: Date

    var startDateComponents: DateComponents? {
        return startDate.components(for: type)
    }
}
