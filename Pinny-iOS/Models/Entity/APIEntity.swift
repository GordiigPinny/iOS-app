//
//  APIEntity.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import SwiftyJSON
import HandyJSON


// MARK: - APIEntity protocol
protocol APIEntity: HandyJSON {
    associatedtype ID: Equatable
    associatedtype Manager: APIEntityManager where Manager.Entity == Self
    
    // Inits
    init()
    init?(json: JSON)
    static func fromJson(json: JSON) -> Self?
    func toJson() -> JSON
    
    // Variables
    var id: ID? { get set }

    var isDetailed: Bool { get }
    
    static var manager: Manager { get }
    
}


extension APIEntity {
    init?(json: JSON) {
        guard let new = Self.fromJson(json: json) else {
            return nil
        }
        self = new
    }
        
    static func fromJson(json: JSON) -> Self? {
        return Self.deserialize(from: json.rawString())
    }
    
    func toJson() -> JSON {
        let str = self.toJSONString(prettyPrint: true)!
        let data = str.data(using: .utf8)!
        let ans = try! JSON(data: data)
        return ans
    }
}
