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
    let referenceDate: Date

    var startDateComponents: DateComponents? {
        return referenceDate.components(for: type)
    }
}
