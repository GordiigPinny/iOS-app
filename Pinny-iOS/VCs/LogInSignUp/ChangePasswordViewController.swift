//
//  ChangePasswordViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class ChangePasswordViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordConfirm: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Variables
    var passwordChangeSubscriber: AnyCancellable?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPassword.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        newPassword.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        newPasswordConfirm.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        activityIndicator.stopAnimating()
        submitButton.isEnabled = isSubmitEnabled
    }

    // MARK: - Actions
    @IBAction func submitButtonPressed(_ sender: Any) {
        let oldPassword = currentPassword.text!
        let newPassword = self.newPassword.text!
        let confirm = newPasswordConfirm.text!
        self.changePassword(oldPassword, newPassword: newPassword, passwordConfirm: confirm)
    }

    @objc func textFieldEditingChanged(_ textField: UITextField) {
        submitButton.isEnabled = isSubmitEnabled
    }

    // MARK: - Request handlers
    private func changePassword(_ oldPassword: String, newPassword: String, passwordConfirm: String) {
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        passwordChangeSubscriber = AuthRequester().changePassword(oldPassword, newPassword, passwordConfirm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.submitButton.isEnabled = self.isSubmitEnabled
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(let err):
                    self.changePasswordFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { token in
                self.changePasswordSuccess(token)
            })
    }

    private func changePasswordSuccess(_ token: Token) {
        Defaults.currentToken = token
        self.presentDefaultOKAlert(title: "Success", msg: "Password is changed!")
        let builder = UIAlertControllerBuilder()
        builder.begin(title: "Success", msg: "Password is changed")
        builder.addAction(title: "OK") { action in 
            self.dismiss(animated: true)
        }
        present(builder.alert!, animated: true)
    }

    private func changePasswordFailure(_ err: URLRequester.RequestError) {
        self.presentDefaultOKAlert(title: "Error on changing password", msg: err.localizedDescription)
    }

    // MARK: - Utils
    private var isSubmitEnabled: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && !newPasswordConfirm.isEmpty &&
                (newPassword.text! == newPasswordConfirm.text!) && (newPassword.text!.count >= 6)
    }

}
