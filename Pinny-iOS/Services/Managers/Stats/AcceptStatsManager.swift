//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class AcceptStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: AcceptStatsManager?

    static var instance: AcceptStatsManager {
        if _instance == nil {
            _instance = AcceptStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [AcceptStats] = []

    var requester: AcceptStatsRequester {
        AcceptStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: AcceptStats, keyPath: KeyPath<AcceptStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }

}
