//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON
import MapKit

final class Profile: APIEntity {
    // MARK: - Variables
    var id: Int?
    var userId: Int!
    var rating: Int!
    var pinSpriteId: Int!
    var geopinSpriteId: Int!
    var money: Int!
    var unlockedPinsId: [Int]!
    var achievementsId: [Int]!
    var picId: Int!

    var isDetailed: Bool {
        rating != nil && pinSpriteId != nil && geopinSpriteId != nil && money != nil
                && unlockedPinsId != nil && achievementsId != nil
    }

    // MARK: - Manager
    static var manager: ProfileManager {
        ProfileManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, userId: Int, rating: Int, pinSpriteId: Int, geopinSpriteId: Int, money: Int,
         unlockedPinsId: [Int], achievementsId: [Int], picId: Int) {
        self.id = id
        self.userId = userId
        self.rating = rating
        self.pinSpriteId = pinSpriteId
        self.geopinSpriteId = geopinSpriteId
        self.money = money
        self.unlockedPinsId = unlockedPinsId
        self.achievementsId = achievementsId
        self.picId = picId
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.userId <-- "user_id"
        mapper <<<
                self.pinSpriteId <-- "pin_sprite"
        mapper <<<
                self.picId <-- "pic_id"
        mapper <<<
                self.geopinSpriteId <-- "geopin_sprite"
        mapper <<<
                self.unlockedPinsId <-- "unlocked_pins"
        mapper <<<
                self.achievementsId <-- "achievements"
    }

    // MARK: - For Apple Map Kit
    class UserMapKitAnnotation: NSObject, MKAnnotation {
        var title: String? = "Me"
        private(set) var coordinate: CLLocationCoordinate2D

        init(coordinate: CLLocationCoordinate2D) {
            self.coordinate = coordinate
        }

    }

    static func mkAnnotation(coordinate: CLLocationCoordinate2D) -> UserMapKitAnnotation {
        UserMapKitAnnotation(coordinate: coordinate)
    }

}
