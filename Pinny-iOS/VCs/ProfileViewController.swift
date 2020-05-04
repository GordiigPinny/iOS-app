//
//  ProfileViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var pinsButton: UIButton!
    @IBOutlet weak var achievementsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!

    // MARK: - Variables
    private var profileGetter: ProfileGetter?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 30
        guard let _ = Defaults.currentProfile else {
            self.getProfile()
            return
        }
        fillView()
    }

    // MARK: - Actions
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func pinsButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: PinListViewController.id)
                as? PinListViewController else {
            presentDefaultOKAlert(title: "Error on instantiating pin list vc", msg: nil)
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func achievementsButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: AchievementListViewController.id)
                as? AchievementListViewController else {
            presentDefaultOKAlert(title: "Error on instantiating achievement list vc", msg: nil)
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: LogInViewController.id)
                as? LogInViewController else {
            presentDefaultOKAlert(title: "Can't instantiate log in vc", msg: nil)
            return
        }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        Defaults.clearAuthData()
        present(navigationController, animated: true)
    }

    // MARK: - Getting profile
    private func getProfile() {
        profileGetter = ProfileGetter()
        profileGetter?.getProfile(
                User.manager.currentUser!.id!,
                completion: profileGetCompletion,
                imageCompletion: avatarGetCompletion)
    }

    private func profileGetCompletion(_ entity: Profile?, _ err: ProfileRequester.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting profile", msg: err.localizedDescription)
                return
            }
            Profile.manager.currentProfile = entity
            self.fillView()
        }
    }

    private func avatarGetCompletion(_ imageFile: ImageFile?, _ image: UIImage?, _ err: ImageFileRequester.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting avatar", msg: err.localizedDescription)
            }
            imageFile?.image = image
            self.avatarImageView.image = image
        }
    }

    // MARK: - Filling view
    private func fillView() {
        let profile = Defaults.currentProfile
        let avatar = Defaults.currentAvatar
        let user = Defaults.currentUser
        usernameLabel.text = user?.username
        emailLabel.text = user?.email
        avatarImageView.image = avatar?.image
    }

}
