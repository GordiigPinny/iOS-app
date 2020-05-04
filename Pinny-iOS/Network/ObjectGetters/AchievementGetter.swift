//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AchievementGetter {
    typealias ApiError = AchievementRequester.ApiError
    typealias ImageCompletion = ImageGetter.Completion
    typealias Entity = Achievement
    typealias Completion = ((Entity?, ApiError?) -> Void)?
    typealias CompletionList = (([Entity]?, ApiError?) -> Void)?

    private var achievementSubscriber: AnyCancellable?
    private var achievementsSubscriber: AnyCancellable?
    private var imageGetter: ImageGetter?

    deinit {
        cancel()
    }

    func cancel() {
        achievementSubscriber?.cancel()
        achievementsSubscriber?.cancel()
        imageGetter?.cancel()
    }

    func getAchievement(_ id: Entity.ID, completion: Completion = nil, imageCompletion: ImageCompletion) {
        achievementSubscriber = Entity.manager.fetch(id: id)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getAchievementFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.getAchievementSuccess(entity, completion, imageCompletion)
            })
    }

    func getAchievements(completion: CompletionList = nil) {
        achievementsSubscriber = AchievementRequester().getList()
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getAchievementsFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.getAchievementsSuccess(entities, completion)
            })
    }

    private func getAchievementSuccess(_ achievement: Entity, _ completion: Completion,
                                       _ imgCompletion: ImageCompletion) {
        Entity.manager.replace(achievement, with: achievement)
        completion?(achievement, nil)
        imageGetter = ImageGetter()
        imageGetter?.getAchievementImage(achievement: achievement, completion: imgCompletion)
    }

    private func getAchievementFailure(_ err: ApiError, _ completion: Completion) {
        completion?(nil, err)
    }

    private func getAchievementsSuccess(_ achievements: [Entity], _ completion: CompletionList) {
        achievements.forEach { Entity.manager.addLocaly($0) }
        completion?(achievements, nil)
    }

    private func getAchievementsFailure(_ err: ApiError, _ completion: CompletionList) {
        completion?(nil, err)
    }

}