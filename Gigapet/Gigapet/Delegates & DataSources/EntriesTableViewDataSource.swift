//
//  EntriesTableViewDataSource.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import CoreData

protocol EntriesTableViewDelegate: AnyObject {
    func entryDeletionDidFail(withError error: Error)
}

class EntriesTableViewDataSource: NSObject, UITableViewDataSource {

    // MARK: - Properties

    var currentDisplayType: EntryDisplayType = .all {
        didSet {
            switchDisplayType()
        }
    }

    weak var tableView: UITableView?
    weak var entryController: FoodEntryController?
    weak var delegate: EntriesTableViewDelegate?

    var entryPeriods = [EntryDisplayPeriod]()

    func switchDisplayType() {
        guard currentDisplayType != .all,
            let entries = entryController?.entries
            else { return }
        entryPeriods = []

        for entry in entries {
            if let periodIndex = entryPeriods.firstIndex(where: {
                $0.startDateComponents == entry.dateFed?.components(for: currentDisplayType)
            }) {
                entryPeriods[periodIndex].entries.append(entry)
            } else {
                entryPeriods.append((EntryDisplayPeriod(
                    type: currentDisplayType,
                    entries: [entry],
                    startDate: entry.dateFed ?? Date())))
            }
        }

        tableView?.reloadData()
    }

    // MARK: - Data Source Methods

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch currentDisplayType {
        case .all:
            return entryController?.entries.count ?? 0
        default: return entryPeriods.count
        }
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
            cell.entry = entryController?.entries[indexPath.row]

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
        if currentDisplayType == .all && editingStyle == .delete,
            let entry = entryController?.entries[indexPath.row] {

            entryController?.deleteFoodEntry(entry) { [weak self] result in
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
