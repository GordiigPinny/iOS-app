//
//  Place.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON
import MapKit

final class Place: APIEntity {
    // MARK: - Variables
    var id: Int?
    var name: String!
    var lat: Double!
    var long: Double!
    var address: String!
    var checkedByModerator: Bool!
    var rating: Double!
    var acceptType: String!
    var createdById: Int!
    var deletedFlg: Bool!
    var myRating: Int?
    var isAcceptedByMe: Bool?
    
    var isDetailed: Bool {
        return myRating != nil && isAcceptedByMe != nil
    }
    
    // MARK: - Manager
    static var manager: PlaceManager {
        PlaceManager.instance
    }

    // MARK: - Some defaults
    static var kremlinCoord: (lat: Double, long: Double) {
        (lat: 55.751694, long: 37.617218)
    }

    static var moscowRadiusForPinch: (lat: Int, long: Int) {
        (lat: 50_000, long: 60_000)
    }

    static var maxDistanceForPinch: Double {
        150_000
    }
    
    // MARK: - Inits
    init() {
        
    }
    
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
    
    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.checkedByModerator <-- "checked_by_moderator"
        mapper <<<
            self.acceptType <-- "accept_type"
        mapper <<<
            self.createdById <-- "created_by"
        mapper <<<
            self.deletedFlg <-- "deleted_flg"
        mapper <<<
            self.myRating <-- "my_rating"
        mapper <<<
            self.isAcceptedByMe <-- "is_accepted_by_me"
        mapper <<<
                self.lat <-- "latitude"
        mapper <<< self.long <-- "longitude"
    }

    // MARK: - For Apple MapKit
    class PlaceMapKitAnnotation: NSObject, MKAnnotation {
        var title: String?
        var subtitle: String?
        private(set) var coordinate: CLLocationCoordinate2D

        init(place: Place) {
            self.title = place.name
            self.subtitle = place.address
            self.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.long)
            super.init()
        }
    }

    var mkAnnotation: PlaceMapKitAnnotation {
        PlaceMapKitAnnotation(place: self)
    }
    
}
