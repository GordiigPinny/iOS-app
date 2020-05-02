//
//  PlaceImagesManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class PlaceImageManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: PlaceImageManager?
    
    static var instance: PlaceImageManager {
        if _instance == nil {
            _instance = PlaceImageManager()
        }
        return _instance!
    }

    private init() {
        
    }
    
    // MARK: - Variables
    var entities: [PlaceImage] = []
    
    var requester: PlaceImageRequester {
        PlaceImageRequester()
    }
    
    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: PlaceImage, keyPath: KeyPath<PlaceImage, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
    
}
