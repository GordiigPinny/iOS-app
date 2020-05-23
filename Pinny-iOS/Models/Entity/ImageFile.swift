//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class ImageFile: APIEntity {
    // MARK: - Enums
    enum ObjectType: String, HandyJSONEnum {
        case place
        case gpin
        case ppin
        case achievement
        case user
    }

    // MARK: - Variables
    var id: Int?
    var _image: UIImage? = nil
    var imageUrl: String? = nil
    var objectId: Int!
    var objectType: ObjectType!
    var createdById: Int!
    var deletedFlg: Bool = false

    var isDetailed: Bool {
        image != nil
    }

    var image: UIImage? {
        get {
            _image == nil ? Self.defaultImage : _image
        }
        set {
            _image = newValue
        }
    }

    static var defaultImage: UIImage {
        UIImage(systemName: "questionmark.circle")!
    }

    // MARK: - Manager
    static var manager: ImageFileManager {
        ImageFileManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, image: UIImage? = nil, imageUrl: String? = nil, objectId: Int, objectType: ObjectType,
         createdById: Int, deletedFlg: Bool = false) {
        self.id = id
        self.image = image
        self.imageUrl = imageUrl
        self.objectId = objectId
        self.objectType = objectType
        self.createdById = createdById
        self.deletedFlg = deletedFlg
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.imageUrl <-- "image_url"
        mapper <<<
                self.objectId <-- "object_id"
        mapper <<<
                self.objectType <-- "object_type"
        mapper <<<
                self.createdById <-- "created_by"
        mapper <<<
                self.deletedFlg <-- "deleted_flg"
    }

    var imageUrlForPostfix: String? {
        var str = self.imageUrl
        str?.removeFirst()
        return str
    }

}
