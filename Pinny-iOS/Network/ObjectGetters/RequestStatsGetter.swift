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
    typealias CompletionList = (([Entity]?, Bool?, ApiError?) -> Void)?

    private var entitySubscriber: AnyCancellable?

    deinit {
        cancel()
    }

    func cancel() {
        entitySubscriber?.cancel()
    }

    func getStats(limit: UInt, offset: UInt, completion: CompletionList = nil) {
        entitySubscriber = RequestStatsRequester().getPaginated(limit: limit, offset: offset)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.getEntityFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entities, hasNext in
                self.getEntitySuccess(entities, hasNext, completion)
            })
    }

    private func getEntitySuccess(_ entities: [Entity], _ hasNext: Bool, _ completion: CompletionList) {
        entities.forEach { Entity.manager.addLocaly($0) }
        completion?(entities, hasNext, nil)
    }

    private func getEntityFailure(_ err: ApiError, _ completion: CompletionList) {
        completion?(nil, nil, err)
    }

}