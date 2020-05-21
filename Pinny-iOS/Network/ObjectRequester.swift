//
//  ObjectRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine
import SwiftyJSON


// MARK: - ApiError enum
enum EntityApiError<Entity: APIEntity>: Error, LocalizedError {
    case requestError(err: URLRequester.RequestError)
    case decodeError(type: Entity.Type)
    
    var localizedDescription: String {
        switch self {
        case .requestError(let err):
            return err.localizedDescription
        case .decodeError(let type):
            return "Error on decoding \(type.self) instance"
        }
    }
    
}


// MARK: - Enum for request type
enum RequestType<T: Equatable> {
    case getList(params: [String : Any] = [:])
    case getPaginated(limit: UInt, offset: UInt, params: [String : Any] = [:])
    case getObject(id: T, params: [String : Any] = [:])
    case postObject
    case patchObject(id: T)
    case deleteObject(id: T)
}


// MARK: - ObjectRequester protocol
protocol ObjectRequester {
    // Types
    associatedtype Entity: APIEntity
    typealias ApiError = EntityApiError<Entity>
    
    // Variables
    var host: URL { get }
    var resource: String { get }
    func urlFor(_ requestType: RequestType<Entity.ID>) -> URL
    
    // Get methods
    func getList(params: [String : Any]) -> AnyPublisher<[Entity], ApiError>
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<([Entity], Bool), ApiError>
    func getObject(_ id: Entity.ID) -> AnyPublisher<Entity, ApiError>
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<Entity, ApiError>
    
    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<Entity, ApiError>
    func patchObject(_ id: Entity.ID, data: Data) -> AnyPublisher<Entity, ApiError>
    
    // Delete methods
    func deleteObject(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError>
    
}

// MARK: - ObjectRequester ext
extension ObjectRequester {
    // URL getter
    func urlFor(_ requestType: RequestType<Entity.ID>) -> URL {
        var ans = host.appendingPathComponent(resource)
        switch requestType {
        case .getList(let params):
            ans = URLRequester.buildUrlWithParams(url: ans, params: params)
        case .getObject(let id, let params):
            ans = ans.appendingPathComponent("\(id)/")
            ans = URLRequester.buildUrlWithParams(url: ans, params: params)
        case .patchObject(let id), .deleteObject(let id):
            ans = ans.appendingPathComponent("\(id)/")
        case .getPaginated(let limit, let offset, let params):
            var allParams = params
            allParams["limit"] = limit; allParams["offset"] = offset
            ans = URLRequester.buildUrlWithParams(url: ans, params: allParams)
        case .postObject:
            break
        }
        return ans
    }
    
    // Helpers
    func mapError(_ err: Error) -> ApiError {
        if let newErr = err as? URLRequester.RequestError {
            return ApiError.requestError(err: newErr)
        }
        if let _ = err as? DecodingError {
            return .decodeError(type: Entity.self)
        }
        if let newErr = err as? ApiError {
            return newErr
        }
        return ApiError.requestError(err: URLRequester.RequestError.unknown)
    }
    
    func simpleTryMap(data: Data) throws -> Entity {
        let json = try JSON(data: data)
        guard let ans = Entity.fromJson(json: json) else {
            throw ApiError.decodeError(type: Entity.self)
        }
        return ans
    }
    
    // Get methods
    func getList(params: [String : Any] = [:]) -> AnyPublisher<[Entity], ApiError> {
        let url = urlFor(.getList(params: params))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> [Entity] in
                let jsonString = String(data: data, encoding: .utf8)!
                guard let ans = [Entity].deserialize(from: jsonString) else {
                    throw ApiError.decodeError(type: Entity.self)
                }
                let nonNilAns = try ans.map { e -> Entity in
                    guard let e = e else {
                        throw ApiError.decodeError(type: Entity.self)
                    }
                    return e
                }
                return nonNilAns
            }
            .mapError { (err) -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<([Entity], Bool), ApiError> {
        let url = urlFor(.getPaginated(limit: limit, offset: offset))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> ([Entity], Bool) in
                let jsonString = String(data: data, encoding: .utf8)
                guard let ans = [Entity].deserialize(from: jsonString, designatedPath: "results") else {
                    throw ApiError.decodeError(type: Entity.self)
                }
                let json = try? JSON(data: data)
                let hasNext = json?["next"].string != nil
                let nonNilAns = try ans.map({ e -> Entity in
                    guard let e = e else {
                        throw ApiError.decodeError(type: Entity.self)
                    }
                    return e
                })
                return (nonNilAns, hasNext)
            }
            .mapError { (err) -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getObject(_ id: Entity.ID) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.getObject(id: id))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data)
                return ans
            }
            .mapError { (err) -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.postObject)
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.post()
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data)
                return ans
            }
            .mapError { (err) -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return publisher
    }

    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<Entity, ApiError> {
        let data = entity.toJSONString()!.data(using: .utf8)!
        return patchObject(id, data: data)
    }

    func patchObject(_ id: Entity.ID, data: Data) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.patchObject(id: id))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.patch(data: data)
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data)
                return ans
            }
            .mapError { (err) -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return publisher
    }

    // Delete methods
    func deleteObject(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError> {
        let url = urlFor(.deleteObject(id: id))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.delete()
            .map { _, response in
                response.statusCode == 204
            }
            .mapError { (err) -> ApiError in
                ApiError.requestError(err: err)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
}


// MARK: - Rating requester
class RatingRequester: ObjectRequester {
    typealias Entity = Rating
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var resource: String {
        "ratings/"
    }
    
}


// MARK: - Accept requester
class AcceptRequester: ObjectRequester {
    typealias Entity = Accept

    func getForPlace(_ place: Place) -> AnyPublisher<[Entity], ApiError> {
        self.getList(params: ["place_id": place.id!])
    }
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var resource: String {
        "accepts/"
    }
    
}


// MARK: - PlaceImage requester
class PlaceImageRequester: ObjectRequester {
    typealias Entity = PlaceImage
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var resource: String {
        "place_images/"
    }
    
}


// MARK: - Place requester
class PlaceRequester: ObjectRequester {
    typealias Entity = Place
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var resource: String {
        "places/"
    }

    func searchByName(_ name: String, onlyMine: Bool? = nil, deletedFlg: Bool? = nil) -> AnyPublisher<[Entity], ApiError> {
        var params: [String : Any] = ["name": name]
        if onlyMine != nil {
            params["only_mine"] = onlyMine!
        }
        if deletedFlg != nil {
            params["with_deleted"] = deletedFlg!
        }
        let ans = self.getList(params: params)
        return ans
    }
    
}


// MARK: - User requester
class UserRequester: ObjectRequester {
    typealias Entity = User
    
    var host: URL {
        Hosts.authHostUrl
    }
    
    var resource: String {
        "users/"
    }

    func getCurrentUser() -> AnyPublisher<User, ApiError> {
        let requester = URLRequester(host: host)
        let ans = requester.get(urlPostfix: "user_info/") 
            .tryMap { data, _ -> User in
                let ans = try self.simpleTryMap(data: data)
                return ans
            }
            .mapError { err -> ApiError in
                let ans = self.mapError(err)
                return ans
            }
            .eraseToAnyPublisher()
        return ans
    }
}


// MARK: - Profile requester
class ProfileRequester: ObjectRequester {
    typealias Entity = Profile

    var host: URL {
        Hosts.profilesHostUrl
    }

    var resource: String {
        "profiles/"
    }

    func changeCurrentPin(_ pin: Pin) -> AnyPublisher<Entity, ApiError> {
        let key = (pin.ptype == .place) ? "pin_sprite" : "geopin_sprite"
        let dictData = [key: pin.id!]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        return self.patchObject(Defaults.currentProfile!.userId!, data: jsonData)
    }

    func changeAvatarId(_ avatarId: Int?) -> AnyPublisher<Entity, ApiError> {
        let dictData = ["pic_id": avatarId]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        return self.patchObject(Defaults.currentProfile!.userId!, data: jsonData)
    }

    func register(username: String, password: String, email: String?) -> AnyPublisher<(Token, User, Profile), ApiError> {
        var data = [
            "username": username,
            "password": password
        ]
        if email != nil {
            data["email"] = email
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let requester = URLRequester(host: Hosts.profilesHostUrl)
        let ans = requester.post(urlPostfix: "profiles/register/", data: jsonData)
        .tryMap { data, response -> (Token, User, Profile) in
            let json = try JSON(data: data)
            let tokenJson = json["token"]
            let userJson = json["user"]
            let profileJson = json["profile"]
            guard let user = User.deserialize(from: userJson.rawString()) else {
                throw ApiError.decodeError(type: Profile.self)
            }
            guard let profile = Profile.deserialize(from: profileJson.rawString()) else {
                throw ApiError.decodeError(type: Profile.self)
            }
            guard let token = Token.deserialize(from: tokenJson.rawString()) else {
                throw ApiError.decodeError(type: Profile.self)
            }
            return (token, user, profile)
        }
        .mapError { error -> ApiError in
            let ans = self.mapError(error)
            return ans
        }
        .eraseToAnyPublisher()
        return ans
    }

}


// MARK: - Pin requester
class PinRequester: ObjectRequester {
    typealias Entity = Pin

    var host: URL {
        Hosts.awardsHostUrl
    }

    var resource: String {
        "pins/"
    }

}


// MARK: - Achievement requester
class AchievementRequester: ObjectRequester {
    typealias Entity = Achievement

    var host: URL {
        Hosts.awardsHostUrl
    }

    var resource: String {
        "achievements/"
    }

}


// MARK: - RequestStats requester
class RequestStatsRequester: ObjectRequester {
    typealias Entity = RequestStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "requests/"
    }

}


// MARK: - PlaceStats requester
class PlaceStatsRequester: ObjectRequester {
    typealias Entity = PlaceStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "places/"
    }

}


// MARK: - AcceptStats requester
class AcceptStatsRequester: ObjectRequester {
    typealias Entity = AcceptStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "accepts/"
    }

}


// MARK: - RatingStats requester
class RatingStatsRequester: ObjectRequester {
    typealias Entity = RatingStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "ratings/"
    }

}


// MARK: - AchievementStats requester
class AchievementStatsRequester: ObjectRequester {
    typealias Entity = AchievementStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "achievements/"
    }

}


// MARK: - PinPurchaseStats requester
class PinPurchaseStatsRequester: ObjectRequester {
    typealias Entity = PinPurchaseStats

    var host: URL {
        Hosts.statsHostUrl
    }

    var resource: String {
        "pin_purchases/"
    }

}


// MARK: - ImageFile requester
class ImageFileRequester: ObjectRequester {
    typealias Entity = ImageFile

    var host: URL {
        Hosts.mediaHostUrl
    }

    var resourcePostfix: String = ""

    var resource: String {
        "images/" + resourcePostfix 
    }



}



