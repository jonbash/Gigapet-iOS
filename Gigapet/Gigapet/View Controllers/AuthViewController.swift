//
//  AuthViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    var authController = AuthController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func authTypeChanged(_ sender: UISegmentedControl) {
    }
}

fileprivate enum AuthType {
    case register, login
}
