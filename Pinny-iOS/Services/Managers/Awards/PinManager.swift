//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class PinManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: PinManager?

    static var instance: PinManager {
        if _instance == nil {
            _instance = PinManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [Pin] = []

    var requester: PinRequester {
        PinRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Pin, keyPath: KeyPath<Pin, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
