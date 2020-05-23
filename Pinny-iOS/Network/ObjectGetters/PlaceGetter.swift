//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PlaceGetter {
    typealias ApiError = PlaceRequester.ApiError
    typealias Entity = Place
    typealias Completion = ((Entity?, ApiError?) -> Void)?
    typealias CompletionList = (([Entity]?, ApiError?) -> Void)?

    private var entitySubscriber: AnyCancellable?
    private var entitiesSubscriber: AnyCancellable?
    private var acceptSubscriber: AnyCancellable?

    deinit {
        cancel()
    }

    func cancel() {
        entitySubscriber?.cancel()
        entitiesSubscriber?.cancel()
    }

    func getPlace(_ id: Entity.ID, completion: Completion = nil) {
        entitySubscriber = Entity.manager.fetch(id: id)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getEntityFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.getEntitySuccess(entity, completion)
            })
    }

    func getPlaces(search: String, onlyMine: Bool? = nil, withDeleted: Bool? = nil, completion: CompletionList = nil) {
        entitiesSubscriber = PlaceRequester().searchByName(search, onlyMine: onlyMine, deletedFlg: withDeleted)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getEntitiesFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.getEntitiesSuccess(entities, completion)
            })
    }

    func getAccept(place: Place) {
        acceptSubscriber = AcceptRequester().getForPlace(place)
            .sink(receiveCompletion: { completion in

            }, receiveValue: { entities in
                entities.forEach { Accept.manager.addLocaly($0) }
            })
    }

    private func getEntitySuccess(_ entity: Entity, _ completion: Completion) {
        Entity.manager.replace(entity, with: entity)
        getAccept(place: entity)
        completion?(entity, nil)
    }

    private func getEntityFailure(_ err: ApiError, _ completion: Completion) {
        completion?(nil, err)
    }

    private func getEntitiesSuccess(_ entities: [Entity], _ completion: CompletionList) {
        entities.forEach { Entity.manager.addLocaly($0) }
        completion?(entities, nil)
    }

    private func getEntitiesFailure(_ err: ApiError, _ completion: CompletionList) {
        completion?(nil, err)
    }

}