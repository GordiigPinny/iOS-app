//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ProfileGetter {
    typealias ApiError = ProfileRequester.ApiError
    typealias ImageCompletion = ImageGetter.Completion
    typealias PinCompletion = PinGetter.Completion
    typealias Entity = Profile
    typealias Completion = ((Entity?, ApiError?) -> Void)?

    private var entitySubscriber: AnyCancellable?
    private var imageGetter: ImageGetter?
    private var ppinGetter: PinGetter?
    private var gpinGetter: PinGetter?

    deinit {
        cancel()
    }

    func cancel() {
        entitySubscriber?.cancel()
        imageGetter?.cancel()
        ppinGetter?.cancel()
        gpinGetter?.cancel()
    }

    func getProfile(_ id: Int, completion: Completion = nil, imageCompletion: ImageCompletion = nil,
                    pinsCompletion: PinCompletion = nil) {
        entitySubscriber = Entity.manager.fetch(id: id)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getEntityFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.getEntitySuccess(entity, completion, imageCompletion, pinsCompletion)
            })
    }

    private func getEntitySuccess(_ entity: Entity, _ completion: Completion,
                                       _ imgCompletion: ImageCompletion, _ pinCompletion: PinCompletion) {
        Entity.manager.replace(entity, with: entity)
        completion?(entity, nil)
        imageGetter = ImageGetter()
        imageGetter?.getAvatar(profile: entity, completion: imgCompletion)
        ppinGetter = PinGetter()
        ppinGetter?.getPlacePin(profile: entity, completion: pinCompletion, imageCompletion: imgCompletion)
        gpinGetter = PinGetter()
        gpinGetter?.getUserPin(profile: entity, completion: pinCompletion, imageCompletion: imgCompletion)
    }

    private func getEntityFailure(_ err: ApiError, _ completion: Completion) {
        completion?(nil, err)
    }

}