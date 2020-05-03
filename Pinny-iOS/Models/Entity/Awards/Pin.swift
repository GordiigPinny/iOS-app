//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


enum PinType: String, HandyJSONEnum {
    case place = "p"
    case user = "g"
}


final class Pin: APIEntity {
    // MARK: - Variables
    var id: Int?
    var name: String!
    var descr: String!
    var price: Int!
    var ptype: PinType!
    var picId: Int!
    var deletedFlg: Bool = false

    var isDetailed: Bool {
        descr != nil
    }

    // MARK: - Manager
    static var manager: PinManager {
        PinManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, name: String, descr: String, price: Int, ptype: PinType, picId: Int, deletedFlg: Bool = false) {
        self.id = id
        self.name = name
        self.descr = descr
        self.price = price
        self.ptype = ptype
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
