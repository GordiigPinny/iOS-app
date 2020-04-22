//
//  SignUpViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 22.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Outlets value getters
    var username: String? {
        usernameTextField.text
    }
    var email: String? {
        emailTextField.text
    }
    var password: String? {
        passwordTextField.text
    }
    var passwordConfirm: String? {
        passwordConfirmTextField.text
    }
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        usernameTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        signUpButton.isEnabled = canPressSignUpButton
    }
    
    // MARK: - Actions
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let username = self.username!
        let email = self.email
        let password = self.password!
        let passwordConfirm = self.passwordConfirm!
        let msg = "username: \(username)\nemail: \(email ?? "nil")\npassword: \(password)\nconfirm: \(passwordConfirm)"
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Implement me!", msg: msg)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions for TextFields
    private var canPressSignUpButton: Bool {
        !usernameTextField.isEmpty && !passwordTextField.isEmpty && !passwordConfirmTextField.isEmpty && (password! == passwordConfirm!)
    }
    @objc func textFieldChangeEditing() {
        signUpButton.isEnabled = canPressSignUpButton
    }
    

}
