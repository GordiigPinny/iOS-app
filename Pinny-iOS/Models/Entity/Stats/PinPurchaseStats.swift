//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class PinPurchaseStats: APIEntity {
    // MARK: - Variables
    var id: Int?
    var pinId: Int!
    var userId: Int!

    var isDetailed: Bool {
        true
    }

    // MARK: - Manager
    static var manager: PinPurchaseStatsManager {
        PinPurchaseStatsManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, pinId: Int, userId: Int) {
        self.id = id
        self.pinId = pinId
        self.userId = userId
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.pinId <-- "pin_id"
        mapper <<<
                self.userId <-- "user_id"
    }

}
