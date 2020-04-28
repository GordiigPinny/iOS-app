//
//  PlaceImage.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import ObjectMapper


final class PlaceImage: APIEntity {
    // MARK: - Variables
    var id: Int?
    var picId: Int
    var placeId: Int
    var createdById: Int?
    var deletedFlg: Bool?
    
    var isDetailed: Bool = false
    
    // MARK: - Manager
    class var manager: PlaceImageManager {
        return PlaceImageManager.instance
    }
    
    // MARK: - Inits
    init(id: Int? = nil, picId: Int, placeId: Int, createdById: Int? = nil, deletedFlg: Bool? = nil) {
        self.id = id
        self.picId = picId
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    // MARK: - Object mapper
    convenience init?(map: Map) {
        self.init(JSON: map.JSON, context: map.context)
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        picId       <- map["pic_id"]
        placeId     <- map["place_id"]
        createdById <- map["created_by"]
        deletedFlg  <- map["deleted_flg"]
        isDetailed = true
    }
    
}
