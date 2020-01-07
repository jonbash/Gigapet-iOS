//
//  AuthViewController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import NetworkHandler

// MARK: - Helper Types

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete(withUserInfo userInfo: UserInfo)
}

enum AuthType {
    case register, login
}

class AuthViewController: UIViewController {

    // MARK: - Properties

    var authController: AuthController?

    weak var delegate: AuthenticationDelegate?

    private var currentAuthType: AuthType = .register {
        didSet { showComponents(forAuthType: currentAuthType) }
    }

    // MARK: - Outlets

    @IBOutlet private weak var petNameStack: UIStackView!
    @IBOutlet private weak var emailStack: UIStackView!

    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var petNameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    @IBOutlet private weak var authenticateButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        emailStack.isHidden = true
    }

    // MARK: - Actions
    
    @IBAction func authTypeChanged(_ sender: UISegmentedControl) {
        currentAuthType = (sender.selectedSegmentIndex == 0) ? .register : .login
    }

    @IBAction func authButtonTapped(_ sender: UIButton) {
        authenticate(forAuthType: currentAuthType)
    }

    // MARK: - Private Methods

    private func showComponents(forAuthType authType: AuthType) {
        if authType == .register {
            petNameStack.isHidden = false
            passwordField.textContentType = .newPassword
            authenticateButton.setTitle("Sign Up", for: .normal)
        } else if authType == .login {
            petNameStack.isHidden = true
            passwordField.textContentType = .password
            authenticateButton.setTitle("Log In", for: .normal)
        }
    }

    private func authenticate(forAuthType authType: AuthType) {
        guard
            let username = usernameField.text, !username.isEmpty,
            let password = passwordField.text, !password.isEmpty
            else { return }

        if authType == .register {
            guard let petName = petNameField.text, !petName.isEmpty
                else { return }

            authController?.register(
                withUsername: username,
                petName: petName,
                password: password
            ) { result in

            }
        } else if authType == .login {
            authController?.logIn(
                withUsername: username,
                password: password,
                completion: handleAuthResult(_:))
        }
    }

    private func handleAuthResult(_ result: Result<UserInfo, Error>) {
        do {
            let userInfo = try result.get()
            delegate?.authenticationDidComplete(withUserInfo: userInfo)
        } catch {
            NSLog("Authentication failed: \(error)")
            showFailureAlert(for: error)
        }
    }

    private func showFailureAlert(for error: Error) {
        present(UIAlertController(error: error), animated: true, completion: nil)
    }
}
