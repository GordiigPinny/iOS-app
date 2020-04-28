//
//  Accept.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import ObjectMapper


final class Accept: APIEntity {
    // MARK: - Variables
    var id: Int?
    var placeId: Int
    var createdById: Int
    var deletedFlg: Bool
    
    var isDetailed: Bool = false
    
    // MARK: - Manager
    class var manager: AcceptManager {
        AcceptManager.instance
    }
    
    // MARK: - inits
    init(id: Int? = nil, placeId: Int, createdById: Int, deletedFlg: Bool) {
        self.id = id
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    
    // MARK: - Object mapper
    convenience init?(map: Map) {
        self.init(JSON: map.JSON, context: map.context)
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        placeId         <- map["place_id"]
        createdById     <- map["created_by"]
        deletedFlg      <- map["deletedFlg"]
        isDetailed = true
    }
    
}
