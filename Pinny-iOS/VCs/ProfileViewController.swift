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
    @IBOutlet weak var statsButton: UIButton!
    
    // MARK: - Variables
    private var profileGetter: ProfileGetter?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 30
        NotificationCenter.default.addObserver(self, selector: #selector(accessLevelChanged), name: .accessLevelChanged, object: nil)
        if Defaults.currentAccessLevel != AccessLevel.anon {
            guard let _ = Defaults.currentProfile else {
                self.getProfile()
                return
            }
        }
        fillView()
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        if Defaults.currentAccessLevel == .anon {
            fillAnonView()
        } else {
            guard let _ = Defaults.currentProfile else {
                self.getProfile()
                return
            }
            fillView()
        }
    }

    @IBAction func changePasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func statsButtonPressed(_ sender: Any) {
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
        switch Defaults.currentAccessLevel {
        case .anon:
            fillAnonView()
            break
        case .admin:
            fillAdminView()
            break
        default:
            fillAuthView()
        }
    }

    private func fillAuthView() {
        let profile = Defaults.currentProfile
        let user = Defaults.currentUser
        usernameLabel.text = user?.username
        emailLabel.text = user?.email
        var avatar: UIImage? = ImageFile.defaultImage
        if let picId = profile?.picId {
            avatar = ImageFile.manager.get(id: picId)?.image
        }
        avatarImageView.image = avatar
        pinsButton.isHidden = false
        achievementsButton.isHidden = false
        changePasswordButton.isHidden = false
        statsButton.isHidden = true
        logOutButton.setTitle("Выйти", for: .normal)
    }

    private func fillAdminView() {
        fillAuthView()
        statsButton.isHidden = false
    }

    private func fillAnonView() {
        usernameLabel.text = "Anon"
        emailLabel.text = "anon"
        pinsButton.isHidden = true
        achievementsButton.isHidden = true
        changePasswordButton.isHidden = true
        statsButton.isHidden = true
        logOutButton.setTitle("Войти", for: .normal)
        avatarImageView.image = ImageFile.defaultImage
    }

}
