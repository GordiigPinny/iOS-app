//
//  AchievementDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class AchievementDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descrLabel: UILabel!

    // MARK: - Variables
    static let id = "AchievementDetailVC"
    private var achievementSubscriber: AnyCancellable?
    private var imageFileSubscriber: AnyCancellable?
    private var imageDwTask: URLSessionDownloadTask?
    private var _achievement = Achievement()
    var achievement: Achievement {
        get {
            _achievement
        }
        set {
            if newValue.isDetailed {
                _achievement = newValue
                fillView()
                return
            }
            _achievement = newValue
            fetchAchievement(newValue)
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageDwTask?.cancel()
    }

    // MARK: - Request handlers
    private func fetchAchievement(_ achievement: Achievement) {
        achievementSubscriber = Achievement.manager.fetch(id: achievement.id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.fetchAchievementFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { achievement in
                self.fetchAchievementSuccess(achievement)
            })
    }

    private func fetchAchievementSuccess(_ achievement: Achievement) {
        Achievement.manager.replace(achievement, with: achievement)
        self.achievement = achievement
        imageFileSubscriber = ImageFile.manager.fetch(id: achievement.picId!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.getImageFileFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { file in
                self.getImageFileSuccess(file)
            })
    }

    private func fetchAchievementFailure(_ err: AchievementRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on fetching achievement", msg: err.localizedDescription)
    }

    private func getImageFileSuccess(_ imageFile: ImageFile) {
        let requester = URLRequester(host: Hosts.mediaHostNoApiUrl)
        imageDwTask = requester.download(urlPostfix: imageFile.imageUrlForPostfix, forObject: imageFile,
                completionHandler: self.getImageCompletion)
    }

    private func getImageFileFailure(_ err: ImageFileRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting image file", msg: err.localizedDescription)
    }

    private func getImageCompletion(_ imageFile: Any?, _ image: UIImage?, _ err: URLRequester.RequestError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image", msg: err.localizedDescription)
                return
            }
            (imageFile as! ImageFile).image = image
            self.fillView()
        }
    }

    // MARK: - Fill view
    private func fillView() {
        if !isViewLoaded { return }
        nameLabel.text = achievement.name
        descrLabel.text = achievement.descr
        let img = ImageFile.manager.get(id: achievement.picId)
        if let img = img {
            imageView.image = img.image
        } else {
            imageView.image = ImageFile.defaultImage
        }

    }

}
