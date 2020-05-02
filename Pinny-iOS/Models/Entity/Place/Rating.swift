//
//  Rating.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class Rating: APIEntity {
    // MARK: - Variables
    var id: Int?
    var rating: Int!
    var placeId: Int!
    var createdById: Int!
    var deletedFlg: Bool!
    var isDetailed: Bool = true
    
    // MARK: - Manager
    class var manager: RatingManager {
        RatingManager.instance
    }
    
    // MARK: - Init
    init() {
        
    }
    
    init(id: Int? = nil, rating: Int, placeId: Int, createdById: Int, deletedFlg: Bool) {
        self.id = id
        self.rating = rating
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    // MARK: - Handy JSON mapper
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.placeId <-- "place_id"
        mapper <<<
            self.createdById <-- "created_by"
        mapper <<<
            self.deletedFlg <-- "deleted_flg"
    }
   
}
