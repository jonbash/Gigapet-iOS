//
//  EntriesViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import PieCharts

class EntriesViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?
    var entriesViewDataSource: EntriesViewDataSource?

    private var currentDisplayType: EntryDisplayType = .all

    @IBOutlet private weak var entriesTableView: UITableView!
    @IBOutlet private weak var timePeriodLabel: UILabel!
    @IBOutlet private weak var entriesChart: PieChart!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        entriesViewDataSource = EntriesViewDataSource(
            foodEntryController: foodEntryController,
            startingDisplayType: currentDisplayType)
        entriesViewDataSource?.delegate = self

        entriesTableView.dataSource = entriesViewDataSource
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

    @IBAction private func previousPeriodTapped(_ sender: UIButton) {
        entriesViewDataSource?.changeDate(incrementing: false)
    }

    @IBAction private func nextPeriodTapped(_ sender: UIButton) {
        entriesViewDataSource?.changeDate(incrementing: true)
    }
    

    // MARK: - Methods

    private func changeDisplayType(to displayType: EntryDisplayType) {
        currentDisplayType = displayType
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedVC = segue.destination as? FeedViewController {
            feedVC.foodEntryController = self.foodEntryController
            feedVC.previousViewController = self

            if segue.identifier == .editEntrySegue,
                let entryIndex = entriesTableView.indexPathForSelectedRow,
                let entryCell = entriesTableView.cellForRow(at: entryIndex)
                    as? EntryTableViewCell,
                let entry = entryCell.entry {

                feedVC.editingEntry = entry
            }
        }
    }
}

// MARK: - Delegates

extension EntriesViewController: UITableViewDelegate {}

extension EntriesViewController: EntriesViewDataDelegate {
    func dataDisplayDidChange() {
        entriesTableView.reloadData()
    }

    func entryDeletionDidFail(withError error: Error) {
        let alert = UIAlertController(error: error)
        self.present(alert, animated: true, completion: nil)
    }
}
