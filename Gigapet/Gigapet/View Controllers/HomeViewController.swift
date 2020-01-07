//
//  HomeViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var foodEntryController: FoodEntryController?
    var authController = AuthController()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userInfo = authController.fetchCurrentUserInfo() {
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
            foodEntryController = nil
            authVC.delegate = self
            authVC.authController = authController
        }
    }

    private func refreshViews(forUser userInfo: UserInfo?) {
        if let userInfo = userInfo {
            foodEntryController = FoodEntryController(user: userInfo)
        }
    }
}

// MARK: - Authentication Delegate

extension HomeViewController: AuthenticationDelegate {
    func authenticationDidComplete(withUserInfo userInfo: UserInfo) {

    }
}
