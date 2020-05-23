//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation

final class ImageFileManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: ImageFileManager?

    static var instance: ImageFileManager {
        if _instance == nil {
            _instance = ImageFileManager()
        }
        return _instance!
    }

    private init() {

    }

    // MARK: - Variables
    var entities: [ImageFile] = []

    var requester: ImageFileRequester {
        ImageFileRequester()
    }

    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: ImageFile, keyPath: KeyPath<ImageFile, T>, value: T) -> Bool
            where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
