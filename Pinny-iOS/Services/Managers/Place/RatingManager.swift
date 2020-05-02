//
//  RatingManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class RatingManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: RatingManager?
    
    static var instance: RatingManager {
        if _instance == nil {
            _instance = RatingManager()
        }
        return _instance!
    }

    private init() {
        
    }
    
    // MARK: - Variables
    var entities: [Rating] = []
    
    var requester: RatingRequester {
        RatingRequester()
    }
    
    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Rating, keyPath: KeyPath<Rating, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
    
}
