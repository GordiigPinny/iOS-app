//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class PlaceStats: APIEntity {
    // MARK: - Enums
    enum Action: String, HandyJSONEnum {
        case opened = "OPENED"
        case created = "CREATED"
        case edited = "EDITED"
        case deleted = "DELETED"
    }

    // MARK: - Variables
    var id: Int?
    var action: Action!
    var placeId: Int!
    var userId: Int? = nil

    var isDetailed: Bool {
        true
    }
    // MARK: - Manager
    static var manager: PlaceStatsManager {
        PlaceStatsManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, action: Action, placeId: Int, userId: Int? = nil) {
        self.id = id
        self.action = action
        self.placeId = placeId
        self.userId = userId
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.placeId <-- "place_id"
        mapper <<<
                self.userId <-- "user_id"
    }
}
