//
// Created by Dmitry Gorin on 02.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import HandyJSON


final class RequestStats: APIEntity {
    // MARK: - Enums
    enum Method: String, HandyJSONEnum {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    // MARK: - Variables
    var id: Int?
    var method: Method!
    var userId: Int? = nil
    var endpoint: String!
    var processTime: Double!
    var statusCode: Int!

    var isDetailed: Bool {
        true
    }

    // MARK: - Manager
    static var manager: RequestStatsManager {
        RequestStatsManager.instance
    }

    // MARK: - Inits
    init() {

    }

    init(id: Int? = nil, method: Method, userId: Int? = nil, endpoint: String, processTime: Double, statusCode: Int) {
        self.id = id
        self.method = method
        self.userId = userId
        self.endpoint = endpoint
        self.processTime = processTime
        self.statusCode = statusCode
    }

    // MARK: - HandyJSON mappings
    func mapping(mapper: HelpingMapper) {
        mapper <<<
                self.userId <-- "user_id"
        mapper <<<
                self.processTime <-- "process_time"
        mapper <<<
                self.statusCode <-- "status_code"
    }
}
