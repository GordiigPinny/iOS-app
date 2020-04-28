//
//  PlaceImage.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class PlaceImage: APIEntity {
    typealias ListDto = PlaceImageListDto
    typealias DetailDto = PlaceImageDetailDto
    
    // MARK: - Variables
    var id: Int?
    var picId: Int
    var placeId: Int
    var createdBy: Int?
    var deletedFlg: Bool?
    
    var isDetailed: Bool = false
    var detailedOnListDto: Bool = true
    
    // MARK: - Inits
    init(picId: Int, placeId: Int, createdBy: Int, deletedFlg: Bool = false, id: Int? = nil) {
        self.id = id
        self.picId = picId
        self.placeId = placeId
        self.createdBy = createdBy
        self.deletedFlg = deletedFlg
    }
    
    class var manager: PlaceImageManager {
        return PlaceImageManager.instance
    }
    
}
