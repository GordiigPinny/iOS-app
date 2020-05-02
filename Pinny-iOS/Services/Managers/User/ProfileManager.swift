//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class ProfileManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: ProfileManager?

    static var instance: ProfileManager {
        if _instance == nil {
            _instance = ProfileManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [Profile] = []

    var requester: ProfileRequester {
        ProfileRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Profile, keyPath: KeyPath<Profile, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }

}
