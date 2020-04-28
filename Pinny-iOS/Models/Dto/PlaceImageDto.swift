//
//  PlaceImageDto.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - List Dto
struct PlaceImageListDto: Dto {
    var id: Int?
    var picId: Int
    var placeId: Int
    var createdBy: Int?
    var deletedFlg: Bool?
    
    func toEntity() -> PlaceImage {
        let ans = PlaceImage(picId: picId, placeId: placeId, createdBy: createdBy ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: PlaceImage) -> PlaceImageListDto {
        let ans = PlaceImageListDto(id: entity.id, picId: entity.picId, placeId: entity.placeId, createdBy: entity.createdBy, deletedFlg: entity.deletedFlg)
        return ans
    }
    
}


struct PlaceImageDetailDto: Dto {
    var id: Int?
    var picId: Int
    var placeId: Int
    var createdBy: Int?
    var deletedFlg: Bool?
    
    func toEntity() -> PlaceImage {
        let ans = PlaceImage(picId: picId, placeId: placeId, createdBy: createdBy ?? 0, deletedFlg: deletedFlg ?? false, id: id)
        ans.isDetailed = true
        return ans
    }
    
    static func fromEntity(_ entity: PlaceImage) -> PlaceImageDetailDto {
        let ans = PlaceImageDetailDto(id: entity.id, picId: entity.picId, placeId: entity.placeId, createdBy: entity.createdBy, deletedFlg: entity.deletedFlg)
        return ans
    }
}
