//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class Achievement: APIEntity {
    // MARK: - Variables
    var id: Int?
    var name: String!
    var descr: String!
    var picId: Int!
    var deletedFlg: Bool = false

    var isDetailed: Bool {
        true
    }

    // MARK: - Manager
    static var manager: AchievementManager {
        AchievementManager.instance
    }

    // MARK: = Inits
    init() {

    }

    init(id: Int? = nil, name: String, descr: String, picId: Int, deletedFlg: Bool = false) {
        self.id = id
        self.name = name
        self.descr = descr
        self.picId = picId
        self.deletedFlg = deletedFlg
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.picId <-- "pic_id"
        mapper <<<
                self.deletedFlg <-- "deleted_flg"
    }

}
