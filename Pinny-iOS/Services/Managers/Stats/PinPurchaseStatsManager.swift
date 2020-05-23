//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class PinPurchaseStatsManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: PinPurchaseStatsManager?

    static var instance: PinPurchaseStatsManager {
        if _instance == nil {
            _instance = PinPurchaseStatsManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [PinPurchaseStats] = []

    var requester: PinPurchaseStatsRequester {
        PinPurchaseStatsRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: PinPurchaseStats, keyPath: KeyPath<PinPurchaseStats, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
