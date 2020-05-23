//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class AchievementStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: AchievementStatsManager?

    static var instance: AchievementStatsManager {
        if _instance == nil {
            _instance = AchievementStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [AchievementStats] = []

    var requester: AchievementStatsRequester {
        AchievementStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: AchievementStats, keyPath: KeyPath<AchievementStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }

}
