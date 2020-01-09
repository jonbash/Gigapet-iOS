//
//  Date+Components.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

extension Date {
    func components(for displayType: EntryDisplayType) -> DateComponents? {
        var components: Set<Calendar.Component>

        switch displayType {
        case .day: components = [.day, .month, .year]
        case .week: components = [.weekOfYear, .year]
        case .month: components = [.month, .year]
        default: return nil
        }

        return Calendar.autoupdatingCurrent.dateComponents(
            components,
            from: self)
    }
}
