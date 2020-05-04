//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class RequestStatsGetter {
    typealias ApiError = RequestStatsRequester.ApiError
    typealias Entity = RequestStats
    typealias Completion = ((Entity?, ApiError?) -> Void)?
    typealias CompletionList = (([Entity]?, ApiError?) -> Void)?

    private var entitySubscriber: AnyCancellable?

    deinit {
        cancel()
    }

    func cancel() {
        entitySubscriber?.cancel()
    }

    func getStats(completion: CompletionList = nil) {
        entitySubscriber = RequestStatsRequester().getList()
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getEntityFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.getEntitySuccess(entities, completion)
            })
    }

    private func getEntitySuccess(_ entities: [Entity], _ completion: CompletionList) {
        entities.forEach { Entity.manager.addLocaly($0) }
        completion?(entities, nil)
    }

    private func getEntityFailure(_ err: ApiError, _ completion: CompletionList) {
        completion?(nil, err)
    }

}