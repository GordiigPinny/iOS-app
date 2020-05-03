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
    private var profileSubscriber: AnyCancellable?
    private var imageFileSubscriber: AnyCancellable?
    private var avatarDownloadTask: URLSessionDownloadTask?

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
        profileSubscriber = ProfileRequester().getObject(Defaults.currentUser!.id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.profileGetFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.profileGetSuccess(entity)
            })
    }

    private func profileGetSuccess(_ profile: Profile) {
        Defaults.currentProfile = profile
        self.fillView()
        imageFileSubscriber = ImageFileRequester().getObject(profile.picId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.imageFileGetFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.imageFileGetSuccess(entity)
            })
    }

    private func profileGetFailure(_ err: ProfileRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting profile", msg: nil)
    }

    private func imageFileGetSuccess(_ imageFile: ImageFile) {
        ImageFile.manager.replace(imageFile, with: imageFile)
        avatarDownloadTask = URLRequester(host: Hosts.mediaHostNoApiUrl)
                .download(urlPostfix: imageFile.imageUrlForPostfix, forObject: imageFile,
                        completionHandler: self.avatarDownloadCompletion)
    }

    private func imageFileGetFailure(_ err: ImageFileRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting image file", msg: nil)
    }

    private func avatarDownloadCompletion(_ imageFile: Any?, _ image: UIImage?, _ err: URLRequester.RequestError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image", msg: err.localizedDescription)
                return
            }
            (imageFile as! ImageFile).image = image
            Defaults.currentAvatar = imageFile as? ImageFile
            self.fillView()
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
