//
//  Globals.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - User defaults store
class Defaults {
    private enum UDKeys: String {
        case currentUser
        case accessToken
        case refreshToken
    }
    
    private static let ud = UserDefaults.standard
    
    static var currentUser: User? {
        get {
            let userStr = ud.string(forKey: UDKeys.currentUser.rawValue)
            return User.deserialize(from: userStr)
        }
        set {
            let userStr = newValue?.toJSONString(prettyPrint: true)
            ud.set(userStr, forKey: UDKeys.currentUser.rawValue)
        }
    }
    
    static var currentToken: Token? {
        get {
            let access = ud.string(forKey: UDKeys.accessToken.rawValue)
            let refresh = ud.string(forKey: UDKeys.refreshToken.rawValue)
            if let access = access, let refresh = refresh {
                return Token(access: access, refresh: refresh)
            }
            return nil
        }
        set {
            ud.set(newValue?.access, forKey: UDKeys.accessToken.rawValue)
            ud.set(newValue?.refresh, forKey: UDKeys.refreshToken.rawValue)
        }
    }
    
}


// MARK: - Hosts
class Hosts {
    static let authHost = "http://127.0.0.1:8000/api/"
    static var authHostUrl: URL {
        return URL(string: authHost)!
    }
    
    static let profilesHost = "http://127.0.0.1:8000/api/"
    static var profilesHostUrl: URL {
        return URL(string: profilesHost)!
    }
    
    static let awardsHost = "http://127.0.0.1:8000/api/"
    static var awardsHostUrl: URL {
        return URL(string: awardsHost)!
    }
    
    static let placesHost = "http://127.0.0.1:8000/api/"
    static var placesHostUrl: URL {
        return URL(string: placesHost)!
    }
    
    static let statsHost = "http://127.0.0.1:8000/api/"
    static var statsHostUrl: URL {
        return URL(string: statsHost)!
    }
    
    static let mediaHost = "http://127.0.0.1:8000/api/"
    static var mediaHostUrl: URL {
        return URL(string: mediaHost)!
    }
    
    static var unauthorizedHeaders: [String : String] {
        let ans = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        return ans
    }

    static var defaultHeaders: [String : String] {
        var headers = unauthorizedHeaders
        if let token = Defaults.currentToken {
            headers["Authorization"] = "Bearer \(token.access)"
        }
        return headers
    }

    static var imageGetHeaders: [String : String] {
        let ans = [
            "Accept": "*/*"
        ]
        return ans
    }
    
}
