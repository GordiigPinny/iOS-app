//
//  ObjectRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine


// MARK: - ApiError enum
enum ApiError: Error, LocalizedError {
    case requestError(err: URLRequester.RequestError)
    case decodeError(err: DecodingError)
    
    var localizedDescription: String {
        switch self {
        case .requestError(let err):
            return err.localizedDescription
        case .decodeError(let err):
            return err.localizedDescription
        }
    }
    
}


// MARK: - Enum for request type
enum RequestType<T: Equatable> {
    case getList
    case getPaginated(limit: UInt, offset: UInt)
    case getObject(id: T)
    case postObject
    case patchObject(id: T)
    case deleteObject(id: T)
}


// MARK: - ObjectRequester protocol
protocol ObjectRequester {
    // Types
    associatedtype Entity: APIEntity
    typealias ListDto = Entity.ListDto
    typealias DetailDto = Entity.DetailDto
    typealias PgDto = Entity.PgDto
    
    // Variables
    var host: URL { get }
    var hostPostfix: String { get }
    func urlFor(_ requestType: RequestType<Entity.ID>) -> URL
    
    // Get methods
    func getList() -> AnyPublisher<[ListDto], ApiError>
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<PgDto, ApiError>
    func getObject(_ id: Entity.ID) -> AnyPublisher<DetailDto, ApiError>
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<ListDto, ApiError>
    func postObject(dto: DetailDto) -> AnyPublisher<ListDto, ApiError>
    
    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<DetailDto, ApiError>
    func patchObject(_ id: Entity.ID, dto: DetailDto) -> AnyPublisher<DetailDto, ApiError>
    
    // Delete methods
    func deleteObject(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError>
    
}

// MARK: - ObjectRequester ext
extension ObjectRequester {
    // URL getter
    func urlFor(_ requestType: RequestType<Entity.ID>) -> URL {
        var ans = host.appendingPathComponent(hostPostfix)
        switch requestType {
        case .getList, .postObject:
            break
        case .getObject(let id), .patchObject(let id), .deleteObject(let id):
            ans = ans.appendingPathComponent("\(id)")
        case .getPaginated(let limit, let offset):
            var ansStr = ans.absoluteString
            ansStr += "?limit=\(limit)&offset=\(offset)"
            ans = URL(string: ansStr)!
        }
        return ans
    }
    
    // Get methods
    func getList() -> AnyPublisher<[ListDto], ApiError> {
        let url = urlFor(.getList)
        let urlRequester = URLRequester(host: url)
        let decoder = JSONDecoder()
        let publisher = urlRequester.get()
            .map { data, _ in
                return data
            }
            .decode(type: [ListDto].self, decoder: decoder)
            .mapError { (err) -> ApiError in
                if let newErr = err as? URLRequester.RequestError {
                    return ApiError.requestError(err: newErr)
                }
                if let newErr = err as? DecodingError {
                    return ApiError.decodeError(err: newErr)
                }
                return ApiError.requestError(err: URLRequester.RequestError.unknown)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<PgDto, ApiError> {
        let url = urlFor(.getPaginated(limit: limit, offset: offset))
        let urlRequester = URLRequester(host: url)
        let decoder = JSONDecoder()
        let publisher = urlRequester.get()
            .map { data, _ in
                return data
            }
            .decode(type: PgDto.self, decoder: decoder)
            .mapError { (err) -> ApiError in
                if let newErr = err as? URLRequester.RequestError {
                    return ApiError.requestError(err: newErr)
                }
                if let newErr = err as? DecodingError {
                    return ApiError.decodeError(err: newErr)
                }
                return ApiError.requestError(err: URLRequester.RequestError.unknown)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getObject(_ id: Entity.ID) -> AnyPublisher<DetailDto, ApiError> {
        let url = urlFor(.getObject(id: id))
        let urlRequester = URLRequester(host: url)
        let decoder = JSONDecoder()
        let publisher = urlRequester.get()
            .map { data, _ in
                return data
            }
            .decode(type: DetailDto.self, decoder: decoder)
            .mapError { (err) -> ApiError in
                if let newErr = err as? URLRequester.RequestError {
                    return ApiError.requestError(err: newErr)
                }
                if let newErr = err as? DecodingError {
                    return ApiError.decodeError(err: newErr)
                }
                return ApiError.requestError(err: URLRequester.RequestError.unknown)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<ListDto, ApiError> {
        return postObject(dto: entity.toDetailDto())
    }
    
    func postObject(dto: DetailDto) -> AnyPublisher<ListDto, ApiError> {
        let url = urlFor(.postObject)
        let urlRequester = URLRequester(host: url)
        let decoder = JSONDecoder()
        let publisher = urlRequester.post()
            .map { data, _ in
                return data
            }
            .decode(type: ListDto.self, decoder: decoder)
            .mapError { (err) -> ApiError in
                if let newErr = err as? URLRequester.RequestError {
                    return ApiError.requestError(err: newErr)
                }
                if let newErr = err as? DecodingError {
                    return ApiError.decodeError(err: newErr)
                }
                return ApiError.requestError(err: URLRequester.RequestError.unknown)
            }
            .eraseToAnyPublisher()
        return publisher
    }

    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<DetailDto, ApiError> {
        return patchObject(id, dto: entity.toDetailDto())
    }
    
    func patchObject(_ id: Entity.ID, dto: DetailDto) -> AnyPublisher<DetailDto, ApiError> {
        let url = urlFor(.patchObject(id: id))
        let urlRequester = URLRequester(host: url)
        let decoder = JSONDecoder()
        let publisher = urlRequester.patch()
            .map { data, _ in
                return data
            }
            .decode(type: DetailDto.self, decoder: decoder)
            .mapError { (err) -> ApiError in
                if let newErr = err as? URLRequester.RequestError {
                    return ApiError.requestError(err: newErr)
                }
                if let newErr = err as? DecodingError {
                    return ApiError.decodeError(err: newErr)
                }
                return ApiError.requestError(err: URLRequester.RequestError.unknown)
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
                return response.statusCode == 204
            }
            .mapError { (err) -> ApiError in
                return ApiError.requestError(err: err)
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
    
    var hostPostfix: String {
        "ratings"
    }
    
}


// MARK: - Accept requester
class AcceptRequester: ObjectRequester {
    typealias Entity = Accept
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var hostPostfix: String {
        "accepts"
    }
    
}


// MARK: - PlaceImage requester
class PlaceImageRequester: ObjectRequester {
    typealias Entity = PlaceImage
    
    var host: URL {
        Hosts.awardsHostUrl
    }
    
    var hostPostfix: String {
        "place_images"
    }
    
}


// MARK: - Place requester
class PlaceRequester: ObjectRequester {
    typealias Entity = Place
    
    var host: URL {
        Hosts.awardsHostUrl
    }
    
    var hostPostfix: String {
        "places"
    }
    
}
