//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class AchievementManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: AchievementManager?

    static var instance: AchievementManager {
        if _instance == nil {
            _instance = AchievementManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [Achievement] = []

    var requester: AchievementRequester {
        AchievementRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Achievement, keyPath: KeyPath<Achievement, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
