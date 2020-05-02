//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class RequestStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: RequestStatsManager?

    static var instance: RequestStatsManager {
        if _instance == nil {
            _instance = RequestStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [RequestStats] = []

    var requester: RequestStatsRequester {
        RequestStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: RequestStats, keyPath: KeyPath<RequestStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
