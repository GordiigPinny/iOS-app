//
//  APIEntity.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - APIEntity protocol
protocol APIEntity: ConvertableToDto {
    associatedtype ID: Equatable
    associatedtype Manager: APIEntityManager where Manager.Entity == Self
    
    var id: ID? { get set }
    
    static var manager: Manager { get }
    
}

