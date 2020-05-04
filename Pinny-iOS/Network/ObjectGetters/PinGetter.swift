//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PinGetter {
    typealias ApiError = PinRequester.ApiError
    typealias ImageCompletion = ImageGetter.Completion
    typealias Entity = Pin
    typealias Completion = ((Entity?, ApiError?) -> Void)?
    typealias CompletionList = (([Entity]?, ApiError?) -> Void)?

    private var pinSubscriber: AnyCancellable?
    private var pinsSubscriber: AnyCancellable?
    private var imageGetter: ImageGetter?

    deinit {
        cancel()
    }

    func cancel() {
        pinSubscriber?.cancel()
        pinsSubscriber?.cancel()
        imageGetter?.cancel()
    }

    func getPlacePin(profile: Profile, completion: Completion = nil, imageCompletion: ImageCompletion = nil) {
        if profile.pinSpriteId != nil {
            getPin(profile.pinSpriteId!, completion: completion, imageCompletion: imageCompletion)
        }
    }

    func getUserPin(profile: Profile, completion: Completion = nil, imageCompletion: ImageCompletion = nil) {
        if profile.geopinSpriteId != nil {
            getPin(profile.geopinSpriteId!, completion: completion, imageCompletion: imageCompletion)
        }
    }

    func getPin(_ id: Entity.ID, completion: Completion = nil, imageCompletion: ImageCompletion = nil) {
        pinSubscriber = Entity.manager.fetch(id: id)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getPinFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.getPinSuccess(entity, completion, imageCompletion)
            })
    }

    func getPins(completion: CompletionList = nil) {
        pinsSubscriber = PinRequester().getList()
        .sink(receiveCompletion: { c in
            switch c {
            case .failure(let err):
                self.getPinsFailure(err, completion)
            case .finished:
                break
            }
        }, receiveValue: { entities in
            self.getPinsSuccess(entities, completion)
        })
    }

    private func getPinSuccess(_ pin: Entity, _ completion: Completion, _ imgCompletion: ImageCompletion) {
        Entity.manager.replace(pin, with: pin)
        completion?(pin, nil)
        imageGetter = ImageGetter()
        imageGetter?.getPinImage(pin: pin, completion: imgCompletion)
    }

    private func getPinFailure(_ err: ApiError, _ completion: Completion) {
        completion?(nil, err)
    }

    private func getPinsSuccess(_ pins: [Entity], _ completion: CompletionList) {
        pins.forEach { Entity.manager.addLocaly($0) }
        completion?(pins, nil)
    }

    private func getPinsFailure(_ err: ApiError, _ completion: CompletionList) {
        completion?(nil, err)
    }

}
