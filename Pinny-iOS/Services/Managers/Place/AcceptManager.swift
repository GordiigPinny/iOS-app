//
//  AcceptManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class AcceptManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: AcceptManager?
    
    static var instance: AcceptManager {
        if _instance == nil {
            _instance = AcceptManager()
        }
        return _instance!
    }

    private init() {
        
    }
    
    // MARK: - Variables
    var entities: [Accept] = []
    
    var requester: AcceptRequester {
        AcceptRequester()
    }
    
    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: Accept, keyPath: KeyPath<Accept, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
}
