//
//  SignUpViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 22.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

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

    // MARK: - Variables
    var signUpSubscriber: AnyCancellable?
    
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
        if password != passwordConfirm {
            presentDefaultOKAlert(title: "Can't sign up", msg: "Different passwords in password and confirm fields")
        }
        signUp(username: username, password: password, email: email)
    }
    
    // MARK: - Actions for TextFields
    private var canPressSignUpButton: Bool {
        !usernameTextField.isEmpty && !passwordTextField.isEmpty && !passwordConfirmTextField.isEmpty &&
                (password! == passwordConfirm!)
    }

    @objc func textFieldChangeEditing() {
        signUpButton.isEnabled = canPressSignUpButton
    }

    // MARK: - Request handlers
    private func signUp(username: String, password: String, email: String?) {
        signUpButton.isEnabled = false
        signUpSubscriber = ProfileRequester().register(username: username, password: password, email: email)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            self.signUpButton.isEnabled = self.canPressSignUpButton
            switch completion {
            case .failure(let err):
                self.signUpCompletion(nil, nil, nil, err)
            case .finished:
                break
            }
        }, receiveValue: { token, user, profile in
            self.signUpCompletion(token, user, profile, nil)
        })
    }

    private func signUpCompletion(_ token: Token?, _ user: User?, _ profile: Profile?, _ err: ProfileRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on sign up", msg: err.localizedDescription)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? UITabBarController else {
            self.presentDefaultOKAlert(title: "Can't instantiate main vc", msg: nil)
            return
        }
        vc.modalPresentationStyle = .fullScreen
        User.manager.currentUser = user!
        Profile.manager.currentProfile = profile!
        Defaults.currentToken = token!
        self.present(vc, animated: true)
    }
    

}
