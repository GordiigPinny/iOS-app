//
//  APIEntity.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import ObjectMapper


// MARK: - APIEntity protocol
protocol APIEntity: Mappable {
    associatedtype ID: Equatable
    associatedtype Manager: APIEntityManager where Manager.Entity == Self
    
    var id: ID? { get set }
    
    var isDetailed: Bool { get set }
    
    static var manager: Manager { get }
    
}


