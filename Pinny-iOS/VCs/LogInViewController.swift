//
//  LogInViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 31.03.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class LogInViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Outlet value getters
    var username: String? {
        usernameTextField.text
    }
    var password: String? {
        passwordTextField.text
    }
    
    // MARK: - Variables
    let authRequester = AuthRequester()
    var subscriber: AnyCancellable?
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        logInButton.isEnabled = canPressLogInButton
    }

    // MARK: - Actions
    @IBAction func logInButtonPressed(_ sender: Any) {
        let username = self.username!
        let password = self.password!
        
        subscriber = authRequester.getToken(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.logInRequestHandlerFailed(err)
                case .finished:
                    break
                }
            }) { token in
                self.logInRequestHandlerSuccess(token)
            }
    }
    
    // MARK: - Actions for TextFields
    private var canPressLogInButton: Bool {
        !usernameTextField.isEmpty && !passwordTextField.isEmpty
    }
    
    @objc func textFieldChangeEditing() {
        logInButton.isEnabled = canPressLogInButton
    }
    
    // MARK: - RequestHandler
    private func logInRequestHandlerSuccess(_ token: Token) {
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Got token", msg: "access: \(token.access)\nrefresh: \(token.refresh)")
        present(alert, animated: true)
    }
    
    private func logInRequestHandlerFailed(_ err: URLRequester.RequestError) {
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Error came", msg: err.localizedDescription)
        present(alert, animated: true)
    }
    
}


// MARK: - UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    
}

