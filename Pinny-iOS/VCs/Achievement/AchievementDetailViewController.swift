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
    private var achievementGetter: AchievementGetter?
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
        achievementGetter?.cancel()
    }

    // MARK: - Request handlers
    private func fetchAchievement(_ achievement: Achievement) {
        achievementGetter = AchievementGetter()
        achievementGetter?.getAchievement(
                achievement.id!,
                completion: getAchievementCompletion,
                imageCompletion: getImageCompletion)
    }

    private func getAchievementCompletion(_ achievement: Achievement?, _ err: AchievementGetter.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on fetching achievement", msg: err.localizedDescription)
            }
            self.achievement = achievement!
        }
    }

    private func getImageCompletion(_ imageFile: ImageFile?, _ image: UIImage?, _ err: ImageFileRequester.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image file", msg: err.localizedDescription)
            }
            imageFile?.image = image
            self.imageView.image = image
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
