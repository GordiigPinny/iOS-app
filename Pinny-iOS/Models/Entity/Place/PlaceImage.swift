//
//  PlaceImage.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class PlaceImage: APIEntity {
    // MARK: - Variables
    var id: Int?
    var picId: Int!
    var placeId: Int!
    var createdById: Int?
    var deletedFlg: Bool?
    
    var isDetailed: Bool = true
    
    // MARK: - Manager
    class var manager: PlaceImageManager {
        return PlaceImageManager.instance
    }
    
    // MARK: - Inits
    init() {
        
    }
    
    init(id: Int? = nil, picId: Int, placeId: Int, createdById: Int? = nil, deletedFlg: Bool? = nil) {
        self.id = id
        self.picId = picId
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.placeId <-- "place_id"
        mapper <<<
            self.createdById <-- "created_by"
        mapper <<<
            self.deletedFlg <-- "deleted_flg"
        mapper <<<
            self.picId <-- "pic_id"
    }
    
}
