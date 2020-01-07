//
//  EntriesTableViewDataSource.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import CoreData

class EntriesTableViewDataSource: NSObject, UITableViewDataSource {

    // MARK: - Properties

    var currentDisplayType: EntryDisplayType = .all
    weak var tableView: UITableView?

    private lazy var fetchedResultsController: NSFetchedResultsController<FoodEntry> = {
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "dateFed", ascending: false)]
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Error initializing fetched results controller: \(error)")
        }

        return frc
        // TODO: sections by day
        // TODO: use cache
    }()

    // MARK: - Data Source Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentDisplayType {
        case .all:
            return fetchedResultsController.fetchedObjects?.count ?? 0
        // TODO: implement other display types
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentDisplayType == .all {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EntryCell",
                for: indexPath)
                as? EntryTableViewCell
                else { return UITableViewCell() }
            cell.entry = fetchedResultsController.object(at: indexPath)

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
