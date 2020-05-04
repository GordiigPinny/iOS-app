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
    var userSubscriber: AnyCancellable?
    var profileGetter: ProfileGetter?
    
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

        signUpSubscriber = AuthRequester().signUp(username: username, password: password, email: email)
            .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let err):
                self.requestFailure(err)
            case .finished:
                break
            }
        }, receiveValue: { token in
            self.signUpRequestSuccess(token)
        })
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
    private func signUpRequestSuccess(_ token: Token) {
        Defaults.currentToken = token
        userSubscriber = UserRequester().getCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.requestFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { user in
                self.getUserRequestSuccess(user)
            })
    }

    private func getUserRequestSuccess(_ user: User) {
        User.manager.currentUser = user
        profileGetter = ProfileGetter()
        profileGetter?.getProfile(user.id!, completion: {entity, error in
            DispatchQueue.main.async {
                Profile.manager.currentProfile = entity
                NotificationCenter.default.post(name: .accessLevelChanged, object: nil)
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting profile", msg: err.localizedDescription)
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateInitialViewController() as? UITabBarController else {
                    self.presentDefaultOKAlert(title: "Can't instantiate main vc", msg: nil)
                    return
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        })
    }

    private func requestFailure(_ err: UserRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on user get", msg: err.localizedDescription)
    }

    private func requestFailure(_ err: URLRequester.RequestError) {
        presentDefaultOKAlert(title: "Error on token get", msg: err.localizedDescription)
    }
    

}
