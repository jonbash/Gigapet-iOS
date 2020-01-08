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

        entriesTableView.dataSource = tableViewDataSource
        entriesTableView.delegate = self
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension EntriesViewController: UITableViewDelegate {

}
