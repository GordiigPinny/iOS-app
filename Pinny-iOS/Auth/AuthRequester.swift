//
//  AuthRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine
import SwiftyJSON


class AuthRequester {
    let requester = URLRequester(host: Hosts.authHostUrl)
    
    func getToken(username: String, password: String) -> AnyPublisher<Token, URLRequester.RequestError> {
        let authDict = ["username": username, "password": password]
        let data = try! JSONSerialization.data(withJSONObject: authDict, options: [.prettyPrinted])
        let ans = requester.post(urlPostfix: "api-token-auth/", data: data, headers: Hosts.unauthorizedHeaders)
            .tryMap { (data: Data, _) -> Token in
                let json = try JSON(data: data)
                let access = json["access"].stringValue
                let refresh = json["refresh"].stringValue
                let ans = Token(access: access, refresh: refresh)
                return ans
            }
            .mapError { (err: Error) -> URLRequester.RequestError in
                    if let _ = err as? DecodingError {
                        return URLRequester.RequestError.apiError(code: 400, descr: "Can't decode tokens")
                    }
                    if let newErr = err as? URLRequester.RequestError {
                        return newErr
                    }
                    return URLRequester.RequestError.unknown
                }
            .eraseToAnyPublisher()
        return ans
    }
    
}
