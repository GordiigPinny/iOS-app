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
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var changeAvatarButton: UIButton!
    
    // MARK: - Variables
    private var profileGetter: ProfileGetter?
    private var avatarChanger: AvatarChanger?

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Defaults.currentAccessLevel == .anon {
            return
        }
        ratingLabel.text = "\(Profile.manager.currentProfile!.rating!)"
        moneyLabel.text = "\(Profile.manager.currentProfile!.money!)"
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
    
    @IBAction func changeAvatarButtonPressed(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            presentDefaultOKAlert(title: "Can't open photo library", msg: "Maybe app hasn't permissions to do so")
            return
        }
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.mediaTypes = ["public.image"]
        vc.allowsEditing = false
        self.present(vc, animated: true)
    }
    
    @IBAction func statsButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: StatsViewController.id)
                as? StatsViewController else {
            presentDefaultOKAlert(title: "Can't instantiate stats vc", msg: nil)
            return
        }
        navigationController?.pushViewController(vc, animated: true)
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
        ratingLabel.text = "\(profile!.rating!)"
        moneyLabel.text = "\(profile!.money!)"
        emailLabel.text = (user?.email ?? "").isEmpty ? "nil" : user?.email
        var avatar: UIImage? = ImageFile.defaultImage
        if let picId = profile?.picId {
            avatar = ImageFile.manager.get(id: picId)?.image
        }
        avatarImageView.image = avatar
        changeAvatarButton.isHidden = false
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
        ratingLabel.text = "0"
        moneyLabel.text = "0"
        changeAvatarButton.isHidden = true
        pinsButton.isHidden = true
        achievementsButton.isHidden = true
        changePasswordButton.isHidden = true
        statsButton.isHidden = true
        logOutButton.setTitle("Войти", for: .normal)
        avatarImageView.image = ImageFile.defaultImage
    }

}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            presentDefaultOKAlert(title: "Error on picking image", msg: "Can't cast it to UIImage")
            return
        }
        picker.dismiss(animated: true)
        avatarChanger = AvatarChanger(profile: Profile.manager.currentProfile!, image: image)
        avatarChanger?.changeAvatar { file, profile, error in
            DispatchQueue.main.async {
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on changing avatar", msg: err.localizedDescription)
                    return
                }
                Profile.manager.currentProfile = profile
                ImageFile.manager.replace(file!, with: file!)
                file?.image = image
                self.avatarImageView.image = image
            }
        }
    }

}
