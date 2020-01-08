//
//  FeedViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?

    @IBOutlet private weak var feedTimePicker: UIDatePicker!
    @IBOutlet private weak var foodCategoryPicker: UIPickerView!
    @IBOutlet private weak var foodNameField: UITextField!
    @IBOutlet private weak var foodAmountField: UITextField!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        feedTimePicker.minimumDate = Date()
    }

    // MARK: - Actions

    @IBAction private func decrementQuantityTapped(_ sender: UIButton) {
    }

    @IBAction private func incrementQuantityTapped(_ sender: UIButton) {
    }

    @IBAction private func feedButtonTapped(_ sender: UIButton) {
    }

}
