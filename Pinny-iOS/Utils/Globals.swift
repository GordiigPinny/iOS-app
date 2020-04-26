//
//  Globals.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


class Hosts {
    static let authHost = "http://127.0.0.1:8000/"
    static var authHostUrl: URL {
        return URL(string: authHost)!
    }
    
    static let profilesHost = "http://127.0.0.1:8000/"
    static var profilesHostUrl: URL {
        return URL(string: profilesHost)!
    }
    
    static let awardsHost = "http://127.0.0.1:8000/"
    static var awardsHostUrl: URL {
        return URL(string: awardsHost)!
    }
    
    static let placesHost = "http://127.0.0.1:8000/"
    static var placesHostUrl: URL {
        return URL(string: placesHost)!
    }
    
    static let statsHost = "http://127.0.0.1:8000/"
    static var statsHostUrl: URL {
        return URL(string: statsHost)!
    }
    
    static let mediaHost = "http://127.0.0.1:8000/"
    static var mediaHostUrl: URL {
        return URL(string: mediaHost)!
    }
    
}
