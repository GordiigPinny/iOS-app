//
//  Place.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import ObjectMapper


final class Place: APIEntity {
    // MARK: - Variables
    var id: Int?
    var name: String
    var lat: Double
    var long: Double
    var address: String
    var checkedByModerator: Bool
    var rating: Double
    var acceptType: String
    var createdById: Int
    var deletedFlg: Bool
    var myRating: Int?
    var isAcceptedByMe: Bool?
    
    var isDetailed: Bool = false
    
    // MARK: - Manager
    static var manager: PlaceManager {
        PlaceManager.instance
    }
    
    // MARK: - Inits
    init(id: Int? = nil, name: String, lat: Double, long: Double, address: String, checkedByModerator: Bool, rating: Double, acceptType: String, createdById: Int, deletedFlg: Bool, myRating: Int? = nil, isAcceptedByMe: Bool? = nil) {
        self.id = id
        self.name = name
        self.lat = lat
        self.long = long
        self.address = address
        self.checkedByModerator = checkedByModerator
        self.rating = rating
        self.acceptType = acceptType
        self.createdById = createdById
        self.deletedFlg = deletedFlg
        self.myRating = myRating
        self.isAcceptedByMe = isAcceptedByMe
    }
    
    // MARK: - Object mapper
    convenience init?(map: Map) {
        self.init(JSON: map.JSON, context: map.context)
    }
    
    func mapping(map: Map) {
        guard let context = map.context as? ContextForMapFromRequest else {
            fatalError("Context has wrong type")
        }
        if context.dtoType == .page {
            fatalError("Can't map page dto to single entity")
        }
        
        id                  <- map["id"]
        name                <- map["name"]
        lat                 <- map["latitude"]
        long                <- map["longitude"]
        address             <- map["address"]
        checkedByModerator <- map["checked_by_moderator"]
        rating              <- map["rating"]
        acceptType          <- map["accept_type"]
        createdById         <- map["created_by"]
        deletedFlg          <- map["deleted_flg"]
        if context.dtoType == .detail {
            myRating            <- map["my_rating"]
            isAcceptedByMe      <- map["is_accepted_by_me"]
            isDetailed = true
        }
    }
    
}
