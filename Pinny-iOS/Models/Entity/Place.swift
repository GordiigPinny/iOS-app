//
//  Place.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


final class Place: APIEntity {
    typealias ListDto = PlaceListDto
    typealias DetailDto = PlaceDetailDto
    
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
    var detailedOnListDto: Bool = false
    
    // MARK: - Inits
    internal init(id: Int? = nil, name: String, lat: Double, long: Double, address: String, checkedByModerator: Bool, rating: Double, acceptType: String, createdById: Int, deletedFlg: Bool, myRating: Int? = nil, isAcceptedByMe: Bool? = nil) {
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
    
    static var manager: PlaceManager {
        PlaceManager.instance
    }
    
}
