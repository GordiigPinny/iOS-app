//
//  PlaceManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class PlaceManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: PlaceManager?
    
    static var instance: PlaceManager {
        if _instance == nil {
            _instance = PlaceManager()
        }
        return _instance!
    }

    private init() {
        
    }
    
    // MARK: - Variables
    var entities: [Place] = []
    
    var requester: PlaceRequester {
        PlaceRequester()
    }
    
    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Place, keyPath: KeyPath<Place, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
    
}
