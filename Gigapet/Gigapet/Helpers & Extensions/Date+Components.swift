//
//  Date+Components.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

// MARK: - Date

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

    func incremented(
        _ incrementing: Bool,
        by displayType: EntryDisplayType
    ) -> Date {
        let change = incrementing ? 1 : -1
        switch displayType {
        case .day:
            return Date(timeIntervalSinceReferenceDate:
                self.timeIntervalSinceReferenceDate
                    + (TimeInterval.day * Double(change)))
        case .week:
            return Date(timeIntervalSinceReferenceDate:
                self.timeIntervalSinceReferenceDate
                    + (TimeInterval.week * Double(change)))
        case .month:
            guard
                let components = self.components(for: .month),
                let month = components.month,
                let year = components.year
                else { return self }
            let newYear = (month == 0 || month == 12) ? (year + change) : year
            let newMonth = month + change
            return DateComponents(year: newYear, month: newMonth).date ?? self
        default:
            return self
        }
    }
}

// MARK: - TimeInterval

extension TimeInterval {
    static let day: TimeInterval = 60 * 60 * 24
    static let week: TimeInterval = TimeInterval.day * 7
}
