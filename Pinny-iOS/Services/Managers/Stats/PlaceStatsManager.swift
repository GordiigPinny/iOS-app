//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class PlaceStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: PlaceStatsManager?

    static var instance: PlaceStatsManager {
        if _instance == nil {
            _instance = PlaceStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [PlaceStats] = []

    var requester: PlaceStatsRequester {
        PlaceStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: PlaceStats, keyPath: KeyPath<PlaceStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
