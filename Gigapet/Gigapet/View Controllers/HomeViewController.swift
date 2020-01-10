//
//  HomeViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties

    var foodEntryController: FoodEntryController?
    var authController = AuthController()

    @IBOutlet private weak var petNameLabel: UILabel!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userInfo = try? authController.fetchCurrentUserInfo() {
            refreshViews(forUser: userInfo)
        } else {
            performSegue(withIdentifier: .showAuthScreenSegue, sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .showAuthScreenSegue,
            let authVC = segue.destination as? AuthViewController {

            refreshViews(forUser: nil)
            foodEntryController?.deleteAllLocalEntries()
            authVC.delegate = self
            authVC.authController = authController
        } else if segue.identifier == .feedPetSegue,
            let feedVC = segue.destination as? FeedViewController {

            feedVC.foodEntryController = foodEntryController
            feedVC.delegate = self
        } else if segue.identifier == .pastEntriesSegue,
            let entriesVC = segue.destination as? EntriesViewController {

            entriesVC.foodEntryController = foodEntryController
        }
    }

    // MARK: - Private

    private func refreshViews(forUser userInfo: UserInfo?) {
        if let userInfo = userInfo {
            foodEntryController = FoodEntryController(user: userInfo)
            petNameLabel.text = userInfo.petname
        } else {
            foodEntryController = nil
            petNameLabel.text = ""
        }
    }
}

// MARK: - Delegates

extension HomeViewController: AuthenticationDelegate {
    func authenticationDidComplete(withUserInfo userInfo: UserInfo) {
        DispatchQueue.main.async {
            self.refreshViews(forUser: userInfo)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension HomeViewController: FeedViewControllerDelegate {
    func entryWasAdded() {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
