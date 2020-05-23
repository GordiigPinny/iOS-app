//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class RatingStats: APIEntity {
    // MARK: - Variables
    var id: Int?
    var placeId: Int!
    var userId: Int!
    var oldRating: Int!
    var newRating: Int!

    var isDetailed: Bool {
        true
    }

    // MARK: - Manager
    static var manager: RatingStatsManager {
        RatingStatsManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, placeId: Int, userId: Int, oldRating: Int, newRating: Int) {
        self.id = id
        self.placeId = placeId
        self.userId = userId
        self.oldRating = oldRating
        self.newRating = newRating
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.placeId <-- "place_id"
        mapper <<<
                self.userId <-- "user_id"
        mapper <<<
                self.oldRating <-- "old_rating"
        mapper <<<
                self.newRating <-- "new_rating"
    }

}
