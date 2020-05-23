//
//  Token.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine
import HandyJSON
import JWTDecode

final class Token: HandyJSON {
    // MARK: - Variables
    private var refreshSubscriber: AnyCancellable?
    var access: String = ""
    var refresh: String = ""
    var refreshRate: TimeInterval {
        guard let decoded = try? decode(jwt: access) else {
            return 60
        }
        guard let unixTimeToEndToken = decoded.body["exp"] as? Int else {
            return 60
        }
        let currentTimestamp = Date().timeIntervalSince1970
        let tokenLifetimeInSeconds = Int(unixTimeToEndToken) - Int(currentTimestamp)
        let halftime = tokenLifetimeInSeconds / 4
        return TimeInterval(halftime)
    }
    
    // MARK: - Inits
    init() {
        
    }
    
    init(access: String, refresh: String) {
        self.access = access
        self.refresh = refresh
    }

    func doRefresh() {
        refreshSubscriber = AuthRequester().refreshToken(token: self)
            .sink(receiveCompletion: { completion in
                switch completion{
                case .failure(let err):
                    print("Can't refresh token! Error: \(err.localizedDescription)")
                    Defaults.createDelayedRefreshTask(withDelay: 10)
                    break
                case .finished:
                    Defaults.createDelayedRefreshTask(withDelay: self.refreshRate)
                    break
                }
            }, receiveValue: { token in
                print("New token: \(token.access)")
                self.access = token.access
            })
    }
    
}

