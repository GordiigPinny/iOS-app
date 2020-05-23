//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class RatingStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: RatingStatsManager?

    static var instance: RatingStatsManager {
        if _instance == nil {
            _instance = RatingStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [RatingStats] = []

    var requester: RatingStatsRequester {
        RatingStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: RatingStats, keyPath: KeyPath<RatingStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
