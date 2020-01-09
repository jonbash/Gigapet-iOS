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

    private var fetchedResultsController: NSFetchedResultsController<FoodEntry>? {
        return entryController?.fetchedResultsController
    }

    var entryPeriods = [EntryDisplayPeriod]()

    func switchDisplayType() {
        guard
            let entries = fetchedResultsController?.fetchedObjects,
            currentDisplayType != .all
            else {
                return
        }
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
            return fetchedResultsController?.fetchedObjects?.count ?? 0
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
            cell.entry = fetchedResultsController?.object(at: indexPath)

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
            let entry = fetchedResultsController?.object(at: indexPath) {

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

// MARK: - FetchedResultsController Delegate

extension EntriesTableViewDataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        tableView?.beginUpdates()
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        (currentDisplayType == .all) ? tableView?.endUpdates() : tableView?.reloadData()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard currentDisplayType == .all else { return }

        switch type {
        case .insert:
            guard
                let newIndexPath = newIndexPath
                else { return }
            tableView?.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard
                let indexPath = indexPath
                else { return }
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard
                let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath
                else { return }
            tableView?.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView?.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView?.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError("Unknown Core Data fetched results change type")
        }
    }
}
