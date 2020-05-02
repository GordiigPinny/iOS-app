//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class AchievementStats: APIEntity {
    // MARK: - Variables
    var id: Int?
    var achievementId: Int!
    var userId: Int!

    var isDetailed: Bool {
        true
    }

    // MARK: - Manager
    static var manager: AchievementStatsManager {
        AchievementStatsManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, achievementId: Int, userId: Int) {
        self.id = id
        self.achievementId = achievementId
        self.userId = userId
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.achievementId <-- "achievement_id"
        mapper <<<
                self.userId <-- "user_id"
    }

}
