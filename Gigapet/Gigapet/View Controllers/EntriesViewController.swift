//
//  EntriesViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import Charts

class EntriesViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?
    var entriesViewDataSource: EntriesViewDataSource?

    private var currentDisplayType: EntryDisplayType = .all

    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    @IBOutlet private weak var entriesTableView: UITableView!
    @IBOutlet private weak var timePeriodLabel: UILabel!
    @IBOutlet private weak var entriesChart: PieChartView!

    @IBOutlet private weak var decrementPeriodButton: UIButton!
    @IBOutlet private weak var incrementPeriodButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        entriesViewDataSource = EntriesViewDataSource(
            foodEntryController: foodEntryController,
            startingDisplayType: currentDisplayType)
        entriesViewDataSource?.delegate = self

        entriesTableView.dataSource = entriesViewDataSource
        entriesTableView.delegate = self

        setDisplay(currentDisplayType)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedCellIndex = entriesTableView.indexPathForSelectedRow {
            entriesTableView.deselectRow(at: selectedCellIndex, animated: true)
        }
        entriesTableView.reloadData()
    }

    // MARK: - Actions

    @IBAction private func displayTypeChanged(_ sender: UISegmentedControl) {
        // I want it to crash if there's an unexpected value given
        setDisplay(EntryDisplayType(rawValue: sender.selectedSegmentIndex)!)
    }

    @IBAction private func previousPeriodTapped(_ sender: UIButton) {
        changePeriod(incrementing: false)
    }

    @IBAction private func nextPeriodTapped(_ sender: UIButton) {
        changePeriod(incrementing: true)
    }

    // MARK: - Display Helpers

    private func setDisplay(_ displayType: EntryDisplayType) {
        currentDisplayType = displayType
        entriesViewDataSource?.change(displayType: displayType)

        let styleIsNotAll = (displayType != .all)
        incrementPeriodButton.isEnabled = styleIsNotAll
        decrementPeriodButton.isEnabled = styleIsNotAll

        updateViews()
    }

    private func changePeriod(incrementing: Bool) {
        entriesViewDataSource?.changeDate(incrementing: incrementing)

        updateViews()
    }

    private func updateViews() {
        setPeriodLabelText()
        entriesTableView.reloadData()
        entriesChart.data = entriesViewDataSource?.getPieChartData()
    }

    // MARK: - String Helpers

    private func setPeriodLabelText() {
        if currentDisplayType == .all {
            timePeriodLabel.text = "All Entries"
            return
        }

        guard let currentReferenceDate = entriesViewDataSource?
            .currentReferenceDate
            else { return }

        switch currentDisplayType {
        case .day:
            timePeriodLabel.text = dayFormatter.string(from: currentReferenceDate)
        case .week:
            timePeriodLabel.text = weekString(from: currentReferenceDate)
        case .month:
            timePeriodLabel.text = monthString(from: currentReferenceDate)
        default: break
        }
    }

    private func weekString(from date: Date) -> String {
        guard
            let components = date.components(for: .week),
            let year = components.yearForWeekOfYear,
            let week = components.weekOfYear
            else { return "?" }
        return "\(year) week \(week)"
    }

    private func monthString(from date: Date) -> String {
        guard
            let components = date.components(for: .month),
            let year = components.year,
            let month = components.month
            else { return "?" }
        return "\(year)-\(month)"
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedVC = segue.destination as? FeedViewController {
            feedVC.foodEntryController = self.foodEntryController
            feedVC.delegate = self

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

extension EntriesViewController: FeedViewControllerDelegate {
    func entryWasAdded() {
        entriesViewDataSource?.entryWasAdded()

        DispatchQueue.main.async {
            self.updateViews()
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
}
