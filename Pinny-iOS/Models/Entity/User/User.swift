//
//  User.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class User: APIEntity {
    // MARK: - Variables
    var id: Int?
    var username: String!
    var email: String!
    var isSuperuser: Bool!
    var isModerator: Bool!
    
    var isDetailed: Bool {
        true
    }
    
    // MARK: - Manager
    static var manager: UserManager {
        return UserManager.instance
    }
    
    // MARK: - Inits
    init() {
        
    }
    
    init(id: Int? = nil, username: String, email: String, isSuperuser: Bool = false, isModerator: Bool = false) {
        self.id = id
        self.username = username
        self.email = email
        self.isSuperuser = isSuperuser
        self.isModerator = isModerator
    }
    
    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.isModerator <-- "is_moderator"
        mapper <<<
            self.isSuperuser <-- "is_superuser"
    }
}
