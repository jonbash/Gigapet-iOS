//
//  EntriesViewDataSource.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Delegate

protocol EntriesViewDataDelegate: AnyObject {
    func dataDisplayDidChange()
    func entryDeletionDidFail(withError error: Error)
}

class EntriesViewDataSource: NSObject {

    // MARK: - Properties

    weak var foodEntryController: FoodEntryController?
    weak var delegate: EntriesViewDataDelegate?

    private(set) var currentDisplayType: EntryDisplayType
    private(set) var entryPeriodsByDisplayType = [EntryDisplayType: [EntryDisplayPeriod]]()
    private var currentReferenceDate = Date()

    // MARK: Computed

    var currentEntryPeriods: [EntryDisplayPeriod] {
        if let currentPeriods = entryPeriodsByDisplayType[currentDisplayType] {
            return currentPeriods
        } else {
            let currentPeriods = entryPeriods(for: currentDisplayType)
            entryPeriodsByDisplayType[currentDisplayType] = currentPeriods
            return currentPeriods
        }
    }
    var currentEntryPeriod: EntryDisplayPeriod? {
        return currentEntryPeriods.first {
            $0.startDateComponents == currentDateComponents
        }
    }

    private var currentDateComponents: DateComponents? {
        currentReferenceDate.components(for: currentDisplayType)
    }

    // MARK: - Init

    init(
        foodEntryController: FoodEntryController?,
        startingDisplayType: EntryDisplayType = .all
    ) {
        self.currentDisplayType = startingDisplayType
        self.foodEntryController = foodEntryController

        super.init()

        self.entryPeriodsByDisplayType = [
            startingDisplayType: entryPeriods(for: startingDisplayType)
        ]
    }

    // MARK: - Entry Periods API

    func change(displayType: EntryDisplayType) {
        self.currentDisplayType = displayType

        delegate?.dataDisplayDidChange()
    }

    func changeDate(incrementing: Bool) {
        currentReferenceDate = currentReferenceDate
            .incremented(incrementing, by: currentDisplayType)

        delegate?.dataDisplayDidChange()
    }

    // MARK: - Private

    private func entryPeriods(
        for displayType: EntryDisplayType
    ) -> [EntryDisplayPeriod] {
        guard let entries = foodEntryController?.entries else { return [] }

        if displayType == .all {
            return [EntryDisplayPeriod(
                type: displayType,
                entries: entries,
                referenceDate: Date())]
        }

        var entryPeriods = [EntryDisplayPeriod]()

        for entry in entries {
            if let periodIndex = entryPeriods.firstIndex(where: {
                $0.startDateComponents == entry
                    .dateFed?.components(for: displayType)
            }) {
                entryPeriods[periodIndex].entries.append(entry)
            } else {
                entryPeriods.append(EntryDisplayPeriod(
                    type: displayType,
                    entries: [entry],
                    referenceDate: entry.dateFed ?? Date()))
            }
        }

        entryPeriods.sort { $0.referenceDate < $1.referenceDate }

        return entryPeriods
    }
}

// MARK: - Table Data Source

extension EntriesViewDataSource: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return currentEntryPeriod?.entries.count ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if currentDisplayType == .all {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EntryCell",
                for: indexPath)
                as? EntryTableViewCell
                else { return UITableViewCell() }
            cell.entry = currentEntryPeriod?.entries[indexPath.row]

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EntryCell",
                for: indexPath)
                as? EntryTableViewCell
                else { return UITableViewCell() }
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete,
            let entry = foodEntryController?.entries[indexPath.row] {

            foodEntryController?.deleteFoodEntry(entry) { [weak self] result in
                DispatchQueue.main.async {
                    if let error = result {
                        self?.delegate?.entryDeletionDidFail(withError: error)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}
