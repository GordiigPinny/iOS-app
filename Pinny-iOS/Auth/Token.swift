//
//  Token.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON

final class Token: HandyJSON {
    // MARK: - Variables
    var access: String = ""
    var refresh: String = ""
    
    // MARK: - Inits
    init() {
        
    }
    
    init(access: String, refresh: String) {
        self.access = access
        self.refresh = refresh
    }
    
}

