//
//  Rating.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class Rating: APIEntity {
    typealias ListDto = RatingListDto
    typealias DetailDto = RatingDetailDto
    
    // MARK: - Variables
    var id: Int?
    var rating: Int
    var placeId: Int
    var createdById: Int
    var deletedFlg: Bool
    var isDetailed: Bool = false
    
    var detailedOnListDto: Bool = true
    
    // MARK: - Inits
    init(rating: Int, placeId: Int, createdById: Int, deletedFlg: Bool = false, id: Int? = nil) {
        self.id = id
        self.rating = rating
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    // MARK: - Manager
    class var manager: RatingManager {
        RatingManager.instance
    }
   
}
