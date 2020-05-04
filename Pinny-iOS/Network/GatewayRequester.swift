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
                guard let place = Place.deserialize(from: newPlaceJson.rawString()) else {
                    throw MyDecodingError.cantDecode(type: "Place")
                }
                Place.manager.addLocaly(place)
                guard let profile = Profile.deserialize(from: updatedProfile.rawString()) else {
                    return (newPlace: place, updatedProfile: nil)
                }
                Profile.manager.currentProfile = profile
                return (newPlace: place, updatedProfile: profile)
            }
            .mapError { error -> ApiError in
                let ans = Self.mapError(error)
                return ans
            }
            .eraseToAnyPublisher()
        return ans
    }

    // MARK: - Utils
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
