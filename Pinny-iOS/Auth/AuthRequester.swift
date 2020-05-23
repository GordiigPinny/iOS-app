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
    // MARK: - Variables
    let requester = URLRequester(host: Hosts.authHostUrl)

    // MARK: - Main request functions
    func getToken(username: String, password: String) -> AnyPublisher<Token, URLRequester.RequestError> {
        let authDict = ["username": username, "password": password]
        let data = try! JSONSerialization.data(withJSONObject: authDict, options: .prettyPrinted)
        let ans = requester.post(urlPostfix: "api-token-auth/", data: data, headers: Hosts.unauthorizedHeaders)
            .tryMap { data, _ -> Token in
                let ans = try self.dataToTokens(data)
                return ans
            }
            .mapError { err -> URLRequester.RequestError in
                let ans = self.mapErrorFromTokens(err)
                return ans
                }
            .eraseToAnyPublisher()
        return ans
    }

    func signUp(username: String, password: String, email: String?) -> AnyPublisher<Token, URLRequester.RequestError> {
        var signUpDict = ["username": username, "password": password]
        if let email = email, !email.isEmpty {
            signUpDict["email"] = email
        }
        let data = try! JSONSerialization.data(withJSONObject: signUpDict, options: .prettyPrinted)
        let ans = requester.post(urlPostfix: "register/", data: data, headers: Hosts.unauthorizedHeaders)
            .tryMap { data, _ -> Token in
                let ans = try self.dataToTokens(data)
                return ans
            }
            .mapError { err -> URLRequester.RequestError in
                let ans = self.mapErrorFromTokens(err)
                return ans
            }
            .eraseToAnyPublisher()
        return ans
    }

    // MARK: - Change password
    func changePassword(_ old: String, _ new: String, _ newConfirm: String) ->
            AnyPublisher<Token, URLRequester.RequestError> {
        let dict = ["old_password": old, "password": new, "password_confirm": newConfirm]
        let dictData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let ans = requester.patch(urlPostfix: "change_password/", data: dictData, headers: Hosts.defaultHeaders)
            .tryMap { data, _ -> Token in
                let ans = try self.dataToTokens(data)
                return ans
            }
            .mapError { err -> URLRequester.RequestError in
                if let _ = err as? DecodingError {
                    return URLRequester.RequestError.apiError(code: 400, descr: "Can't decode tokens")
                }
                if let newErr = err as? URLRequester.RequestError {
                    switch newErr {
                    case .apiError(let code, let descr):
                        return URLRequester.RequestError.apiError(code: code, descr: descr +
                                "\nMaybe old password is wrong?")
                    default:
                        return newErr
                    }
                }
                return URLRequester.RequestError.unknown
            }
            .eraseToAnyPublisher()
        return ans
    }

    // Refresh token
    func refreshToken(token: Token) -> AnyPublisher<Token, URLRequester.RequestError> {
        let data = ["refresh": token.refresh]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let ans = requester.post(urlPostfix: "api-token-refresh/", data: jsonData, headers: Hosts.unauthorizedHeaders)
            .tryMap { data, response -> Token in
                let json = try JSON(data: data)
                let access = json["access"].stringValue
                let ans = Token(access: access, refresh: token.refresh)
                return ans
            }
            .mapError { error -> URLRequester.RequestError in
                let ans = self.mapErrorFromTokens(error)
                return ans
            }
            .eraseToAnyPublisher()
        return ans
    }

    // MARK: - Handy privates
    private func dataToTokens(_ data: Data) throws -> Token {
        let json = try JSON(data: data)
        let access = json["access"].stringValue
        let refresh = json["refresh"].stringValue
        let ans = Token(access: access, refresh: refresh)
        return ans
    }

    private func mapErrorFromTokens(_ err: Error) -> URLRequester.RequestError {
        if let _ = err as? DecodingError {
            return URLRequester.RequestError.apiError(code: 400, descr: "Can't decode tokens")
        }
        if let newErr = err as? URLRequester.RequestError {
            return newErr
        }
        return URLRequester.RequestError.unknown
    }
    
}
