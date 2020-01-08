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
            refreshViews(forUser: nil)
            performSegue(withIdentifier: .showAuthScreenSegue, sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .showAuthScreenSegue,
            let authVC = segue.destination as? AuthViewController {
            foodEntryController = nil
            authVC.delegate = self
            authVC.authController = authController
        }
    }

    // MARK: - Private

    private func refreshViews(forUser userInfo: UserInfo?) {
        if let userInfo = userInfo {
            foodEntryController = FoodEntryController(user: userInfo)
            petNameLabel.text = userInfo.petname
        } else {
            foodEntryController = nil
            petNameLabel.text = "My Pet Name"
        }
    }
}

// MARK: - Authentication Delegate

extension HomeViewController: AuthenticationDelegate {
    func authenticationDidComplete(withUserInfo userInfo: UserInfo) {
        refreshViews(forUser: userInfo)
    }
}
