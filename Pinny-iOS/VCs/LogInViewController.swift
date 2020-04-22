//
//  LogInViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 31.03.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Outlet value getters
    var username: String {
        usernameTextField.text!
    }
    var password: String {
        passwordTextField.text!
    }
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
    }

    // MARK: - Actions
    @IBAction func logInButtonPressed(_ sender: Any) {
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Implement me", msg: "username: \(username)\npassword: \(password)")
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions for TextFields
    private var canPressLogInButton: Bool {
        usernameTextField.isEmpty && passwordTextField.isEmpty
    }
    
    @objc func textFieldChangeEditing() {
        logInButton.isEnabled = canPressLogInButton
    }
    
}


// MARK: - TextField extension
extension LogInViewController: UITextFieldDelegate {
    
}

