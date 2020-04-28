//
//  RatingDto.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - List Dto
struct RatingListDto: Dto {
    // MARK: - Variables
    var id: Int?
    var rating: Int
    var createdById: Int? = nil
    var placeId: Int
    var deletedFlg: Bool? = nil
    
    func toEntity() -> Rating {
        let ans = Rating(rating: rating, placeId: placeId, createdById: createdById ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: Rating) -> RatingListDto {
        let ans = RatingListDto(id: entity.id, rating: entity.rating, createdById: entity.createdById, placeId: entity.placeId, deletedFlg: entity.deletedFlg)
        return ans
    }
    
}


// MARK: - Detail Dto
struct RatingDetailDto: Dto {
    // MARK: - Variables
    var id: Int?
    var rating: Int
    var createdById: Int? = nil
    var placeId: Int
    var deletedFlg: Bool? = nil
    
    func toEntity() -> Rating {
        let ans = Rating(rating: rating, placeId: placeId, createdById: createdById ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: Rating) -> RatingDetailDto {
        let ans = RatingDetailDto(id: entity.id, rating: entity.rating, createdById: entity.createdById, placeId: entity.placeId, deletedFlg: entity.deletedFlg)
        return ans
    }
    
}
