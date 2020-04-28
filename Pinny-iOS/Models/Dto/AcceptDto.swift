//
//  AcceptDto.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - List Dto
struct AcceptListDto: Dto {
    var id: Int?
    var placeId: Int
    var createdById: Int?
    var deletedFlg: Bool?
    
    func toEntity() -> Accept {
        let ans = Accept(placeId: placeId, createdById: createdById ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: Accept) -> AcceptListDto {
        let ans = AcceptListDto(id: entity.id, placeId: entity.placeId, createdById: entity.createdById, deletedFlg: entity.deletedFlg)
        return ans
    }
    
}


// MARK: - Detail Dto
struct AcceptDetailDto: Dto {
    // MARK: - Variables
    var id: Int?
    var placeId: Int
    var createdById: Int?
    var deletedFlg: Bool?
    
    func toEntity() -> Accept {
        let ans = Accept(placeId: placeId, createdById: createdById ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: Accept) -> AcceptDetailDto {
        let ans = AcceptDetailDto(id: entity.id, placeId: entity.placeId, createdById: entity.createdById, deletedFlg: entity.deletedFlg)
        return ans
    }
    
}
