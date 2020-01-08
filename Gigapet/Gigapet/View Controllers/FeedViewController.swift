//
//  FeedViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import NetworkHandler

class FeedViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?
    var editingEntry: FoodEntry?

    weak var previousViewController: UIViewController?

    @IBOutlet private weak var feedTimePicker: UIDatePicker!
    @IBOutlet private weak var foodCategoryPicker: UIPickerView!
    @IBOutlet private weak var foodNameField: UITextField!
    @IBOutlet private weak var foodAmountField: UITextField!

    @IBOutlet private weak var feedButton: GigaPetButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        foodCategoryPicker.dataSource = self
        foodCategoryPicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if editingEntry != nil {
            feedButton.setTitle("Update Entry", for: .normal)
        } else {
            feedButton.setTitle("Feed My Pet!", for: .normal)
        }
    }

    // MARK: - Actions

    @IBAction private func decrementQuantityTapped(_ sender: UIButton) {
        changeQuantity(incrementing: false)
    }

    @IBAction private func incrementQuantityTapped(_ sender: UIButton) {
        changeQuantity(incrementing: true)
    }

    @IBAction private func feedButtonTapped(_ sender: UIButton) {
        feedPet()
    }

    // MARK: - Private Methods

    private func changeQuantity(incrementing: Bool) {
        guard
            let foodAmountText = foodAmountField.text,
            var foodAmount = Int(foodAmountText)
            else {
                foodAmountField.text = String(1)
                return
        }

        foodAmount += incrementing ? 1 : -1
        if foodAmount <= 0 {
            return
        }

        foodAmountField.text = String(foodAmount)
    }

    private func feedPet() {
        let categoryIndex = foodCategoryPicker.selectedRow(inComponent: 0)
        let category = FoodCategory.allCases[categoryIndex]
        let dateFed = feedTimePicker.date

        guard
            let foodName = foodNameField.text, !foodName.isEmpty,
            let foodAmountString = foodAmountField.text,
            let foodAmount = Int(foodAmountString)
            else { return }

        if let entry = editingEntry {
            foodEntryController?.updateFoodEntry(
                entry,
                withCategory: category,
                foodName: foodName,
                foodAmount: foodAmount,
                timestamp: dateFed,
                completion: handleResponse(_:))
        } else {
            foodEntryController?.addEntry(
                category: category,
                foodName: foodName,
                foodAmount: foodAmount,
                completion: handleResponse(_:))
        }
    }

    private func handleResponse(_ error: NetworkError?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                let alert = UIAlertController(error: error)
                self?.present(alert, animated: true, completion: nil)
                return
            }
            if let previous = self?.previousViewController {
                self?.navigationController?
                    .popToViewController(previous, animated: true)
            } else {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: - Category Picker Data Source

extension FeedViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return FoodCategory.allCases.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return FoodCategory.allCases[row].rawValue.capitalized
    }
}
