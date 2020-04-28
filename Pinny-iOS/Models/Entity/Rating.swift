//
//  Rating.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import ObjectMapper


final class Rating: APIEntity {
    // MARK: - Variables
    var id: Int?
    var rating: Int
    var placeId: Int
    var createdById: Int
    var deletedFlg: Bool
    var isDetailed: Bool = false
    
    // MARK: - Manager
    class var manager: RatingManager {
        RatingManager.instance
    }
    
    // MARK: - Init
    init(id: Int? = nil, rating: Int, placeId: Int, createdById: Int, deletedFlg: Bool) {
        self.id = id
        self.rating = rating
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
        rating          <- map["rating"]
        placeId         <- map["place_id"]
        createdById     <- map["created_by"]
        deletedFlg      <- map["deletedFlg"]
        isDetailed = true
    }
   
}
