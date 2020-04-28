//
//  Accept.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class Accept: APIEntity {    
    typealias ListDto = AcceptListDto
    typealias DetailDto = AcceptDetailDto
    
    // MARK: - Variables
    var id: Int?
    var placeId: Int
    var createdById: Int
    var deletedFlg: Bool
    
    var isDetailed: Bool = false
    var detailedOnListDto: Bool = true
    
    // MARK: - inits
    init(placeId: Int, createdById: Int, deletedFlg: Bool = false, id: Int? = nil) {
        self.id = id
        self.placeId = placeId
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }
    
    class var manager: AcceptManager {
        AcceptManager.instance
    }
    
    
}
