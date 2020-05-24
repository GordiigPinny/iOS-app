//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import Combine
import SwiftyJSON


private enum MyDecodingError: Error, LocalizedError {
    case cantDecode(type: String)

    var localizedDescription: String {
        switch self {
        case .cantDecode(let type):
            return type
        }
    }
}


class GatewayRequester {
    typealias ApiError = URLRequester.RequestError

    static func createPlace(name: String, address: String, lat: Double, long: Double)
                    -> AnyPublisher<(newPlace: Place?, updatedProfile: Profile?), ApiError> {
        let requester = URLRequester(host: Hosts.gatewayHostUrl)
        let dictData: [String : Any] = [
            "name": name,
            "address": address,
            "lat": lat,
            "long": long
        ]
        let data = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        let ans = requester.post(urlPostfix: "gateway/add_place/", data: data)
            .tryMap { data, response -> (newPlace: Place?, updatedProfile: Profile?) in
                let json = try JSON(data: data)
                let newPlaceJson = json["place"]
                let updatedProfile = json["profile"]
                let place: Place = try Self.decodeEntity(json: newPlaceJson, name: "Place")
                guard let profile = Self.decodeProfile(json: updatedProfile) else {
                    return (newPlace: place, updatedProfile: nil)
                }
                return (newPlace: place, updatedProfile: profile)
            }
            .mapError { error -> ApiError in
                let ans = Self.mapError(error)
                return ans
            }
            .eraseToAnyPublisher()
        return ans
    }

    static func updateRating(placeId: Int, rating: Int) -> AnyPublisher<(rating: Rating, profile: Profile?), ApiError> {
        let dictData: [String : Any] = [
            "place_id": placeId,
            "rating": rating
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        let requester = URLRequester(host: Hosts.gatewayHostUrl)
        let ans = requester.post(urlPostfix: "gateway/add_rating/", data: jsonData)
            .tryMap { data, response -> (rating: Rating, profile: Profile?) in
                let json = try JSON(data: data)
                let ratingJson = json["rating"]
                let profileJson = json["profile"]
                let rating: Rating = try Self.decodeEntity(json: ratingJson, name: "rating")
                Place.manager.get(id: placeId)?.myRating = rating.rating
                if let newGlobalRating = ratingJson["current_rating"].double {
                    Place.manager.get(id: placeId)?.rating = newGlobalRating
                }
                guard let profile = self.decodeProfile(json: profileJson) else {
                    return (rating: rating, profile: nil)
                }
                return (rating: rating, profile: profile)
            }
            .mapError { error -> ApiError in
                self.mapError(error)
            }
            .eraseToAnyPublisher()
        return ans
    }

    static func addAccept(place: Place) -> AnyPublisher<(accept: Accept, profile: Profile?), ApiError> {
        let dictData: [String : Any] = [
            "place_id": place.id!
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        let requester = URLRequester(host: Hosts.gatewayHostUrl)
        let ans = requester.post(urlPostfix: "gateway/add_acceptance/", data: jsonData)
            .tryMap { data, response -> (accept: Accept, profile: Profile?) in
                let json = try JSON(data: data)
                let acceptJson = json["accept"]
                let profileJson = json["profile"]
                let accept: Accept = try Self.decodeEntity(json: acceptJson, name: "Accept")
                place.isAcceptedByMe = true
                Accept.manager.addLocaly(accept)
                if let currentAcceptType = acceptJson["current_accept_type"].string {
                    place.acceptType = currentAcceptType
                    Place.manager.replace(place, with: place)
                }
                guard let profile = self.decodeProfile(json: profileJson) else {
                    return (accept: accept, profile: nil)
                }
                return (accept: accept, profile: profile)
            }
            .mapError { error -> ApiError in
                self.mapError(error)
            }
            .eraseToAnyPublisher()
        return ans
    }

    static func deleteAccept(acceptId: Int) -> AnyPublisher<Profile?, ApiError> {
        let requester = URLRequester(host: Hosts.gatewayHostUrl)
        let ans = requester.delete(urlPostfix: "gateway/delete_acceptance/\(acceptId)/")
            .tryMap { data, response -> Profile? in
//                Accept.manager.delete(acceptId)
//                let json = try JSON(data: data)
//                let profileJson = json["profile"]
//                guard let profile = self.decodeProfile(json: profileJson) else {
//                    return nil
//                }
//                return profile
            return nil
            }
            .mapError { error -> ApiError in
                self.mapError(error)
            }
            .eraseToAnyPublisher()
        return ans
    }

    static func buyPin(pin: Pin) -> AnyPublisher<Profile?, ApiError> {
        let dictData: [String : Any] = [
            "pin_id": pin.id!
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        let requester = URLRequester(host: Hosts.gatewayHostUrl)
        let ans = requester.post(urlPostfix: "gateway/buy_pin/", data: jsonData)
            .tryMap { data, response -> Profile? in
                let json = try JSON(data: data)
                guard let profile = Self.decodeProfile(json: json) else {
                    throw MyDecodingError.cantDecode(type: "Profile")
                }
                Profile.manager.currentProfile = profile
                return profile
            }
            .mapError { error -> ApiError in
                self.mapError(error)
            }
            .eraseToAnyPublisher()
        return ans
    }

    // MARK: - Utils
    private static func decodeEntity<T: APIEntity>(json: JSON, name: String) throws -> T {
        guard let entity = T.deserialize(from: json.rawString()) else {
            throw MyDecodingError.cantDecode(type: name)
        }
        T.manager.addLocaly(entity)
        return entity
    }

    private static func decodeProfile(json: JSON) -> Profile? {
        guard let profile = Profile.deserialize(from: json.rawString()) else {
            return nil
        }
        Profile.manager.currentProfile = profile
        return profile
    }

    private static func mapError(_ error: Error) -> ApiError {
        if let _ = error as? DecodingError {
            return ApiError.apiError(code: -1, descr: "Decoding error")
        }
        if let err = error as? MyDecodingError {
            return ApiError.apiError(code: -1, descr: "Can't decode \(err.localizedDescription)")
        }
        if let err = error as? ApiError {
            return err
        }
        return ApiError.unknown
    }

}
