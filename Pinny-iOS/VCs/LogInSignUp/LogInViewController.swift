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
    @IBOutlet weak var anonButton: UIButton!
    
    // MARK: - Outlet value getters
    var username: String? {
        usernameTextField.text
    }
    var password: String? {
        passwordTextField.text
    }
    
    // MARK: - Variables
    static let id = "LogInVC"
    let authRequester = AuthRequester()
    var tokenSubscriber: AnyCancellable?
    var userSubscriber: AnyCancellable?
    var profileGetter: ProfileGetter?
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldChangeEditing), for: .editingChanged)
        logInButton.isEnabled = canPressLogInButton

        usernameTextField.text = "gordiig"
        passwordTextField.text = "Qweasdzxc123"
        logInButton.isEnabled = true
    }

    // MARK: - Actions
    @IBAction func logInButtonPressed(_ sender: Any) {
        let username = self.username!
        let password = self.password!

        logInButton.isEnabled = false
        tokenSubscriber = authRequester.getToken(username: username, password: password)
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
    
    @IBAction func anonButtonPressed(_ sender: Any) {
        Defaults.clearAuthData()
        NotificationCenter.default.post(name: .accessLevelChanged, object: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? UITabBarController else {
            presentDefaultOKAlert(title: "Can't instantiate initail vc", msg: nil)
            return
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
        Defaults.currentToken = token
        userSubscriber = UserRequester().getCurrentUser()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let err):
                self.userRequestHandlerFailed(err)
            case .finished:
                break
            }
        }, receiveValue: { user in
            self.userRequestHandlerSuccess(user)
        })
    }
    
    private func logInRequestHandlerFailed(_ err: URLRequester.RequestError) {
        self.logInButton.isEnabled = self.canPressLogInButton
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Error came", msg: err.localizedDescription)
        present(alert, animated: true)
    }

    private func userRequestHandlerSuccess(_ user: User) {
        User.manager.currentUser = user
        profileGetter = ProfileGetter()
        profileGetter?.getProfile(user.id!, completion: { entity, error in
            DispatchQueue.main.async {
                self.logInButton.isEnabled = self.canPressLogInButton
                Profile.manager.currentProfile = entity
                NotificationCenter.default.post(name: .accessLevelChanged, object: nil)
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting profile", msg: err.localizedDescription)
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateInitialViewController() as? UITabBarController else {
                    self.presentDefaultOKAlert(title: "Can't instantiate main VC", msg: nil)
                    return
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        })
    }

    private func userRequestHandlerFailed(_ err: UserRequester.ApiError) {
        self.logInButton.isEnabled = self.canPressLogInButton
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Error", msg: err.localizedDescription)
        present(alert, animated: true)
    }
    
}


// MARK: - UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    
}

