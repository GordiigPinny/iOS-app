//
//  UserManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class UserManager: APIEntityManager {
    // MARK: - Singletone
    private static var _instance: UserManager?
    
    static var instance: UserManager {
        if _instance == nil {
            _instance = UserManager()
        }
        return _instance!
    }

    private init() {
        
    }
    
    // MARK: - Variables
    var entities: [User] = []
    
    var requester: UserRequester {
        UserRequester()
    }
    
    // MARK: - Needed for protocol
    func checkEntityWithKeyPath<T>(_ entity: User, keyPath: KeyPath<User, T>, value: T) -> Bool where T : Equatable {
        return entity[keyPath: keyPath] == value
    }
    
}
