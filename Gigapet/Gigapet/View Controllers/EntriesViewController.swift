//
//  EntriesViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class EntriesViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?
    lazy var tableViewDataSource = EntriesTableViewDataSource()

    private var currentDisplayType: EntryDisplayType = .all

    @IBOutlet private weak var entriesTableView: UITableView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewDataSource.currentDisplayType = currentDisplayType
        tableViewDataSource.tableView = entriesTableView
        tableViewDataSource.entryController = foodEntryController
        tableViewDataSource.delegate = self

        entriesTableView.dataSource = tableViewDataSource
        entriesTableView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedCellIndex = entriesTableView.indexPathForSelectedRow {
            entriesTableView.deselectRow(at: selectedCellIndex, animated: true)
        }
        entriesTableView.reloadData()
    }

    // MARK: - Actions

    @IBAction private func periodControlChanged(_ sender: UISegmentedControl) {
        // I want it to crash if there's an unexpected value given
        changeDisplayType(to: EntryDisplayType(rawValue:
            sender.selectedSegmentIndex)!)
    }

    // MARK: - Methods

    private func changeDisplayType(to displayType: EntryDisplayType) {
        currentDisplayType = displayType
        tableViewDataSource.currentDisplayType = displayType

        entriesTableView.reloadData()
    }

    func refreshFromServer() {

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .editEntrySegue,
            let feedVC = segue.destination as? FeedViewController,
            let entryIndex = entriesTableView.indexPathForSelectedRow,
            let entryCell = entriesTableView.cellForRow(at: entryIndex)
                as? EntryTableViewCell,
            let entry = entryCell.entry {

            feedVC.editingEntry = entry
            feedVC.foodEntryController = self.foodEntryController
            feedVC.previousViewController = self
        }
    }
}

// MARK: - Delegate

extension EntriesViewController: UITableViewDelegate {}

extension EntriesViewController: EntriesTableViewDelegate {
    func entryDeletionDidFail(withError error: Error) {
        let alert = UIAlertController(error: error)
        self.present(alert, animated: true) {
            self.refreshFromServer()
        }
    }
}
