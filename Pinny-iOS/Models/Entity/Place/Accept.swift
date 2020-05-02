//
//  Accept.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class Accept: APIEntity {
    // MARK: - Variables
    var id: Int?
    var placeId: Int!
    var createdById: Int!
    var deletedFlg: Bool!
    
    var isDetailed: Bool = true
    
    // MARK: - Manager
    class var manager: AcceptManager {
        AcceptManager.instance
    }
    
    // MARK: - inits
    init() {
        
    }
    
    init(id: Int? = nil, placeId: Int, createdById: Int, deletedFlg: Bool) {
        self.id = id
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    
    // MARK: - HandyJSON mapping
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.createdById <-- "created_by"
        mapper <<<
            self.deletedFlg <-- "deleted_flg"
        mapper <<<
            self.placeId <-- "place_id"
    }
    
}
