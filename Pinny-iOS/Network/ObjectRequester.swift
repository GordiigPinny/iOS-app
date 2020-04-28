//
//  ObjectRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine
import ObjectMapper


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
    case getList
    case getPaginated(limit: UInt, offset: UInt)
    case getObject(id: T)
    case postObject
    case patchObject(id: T)
    case deleteObject(id: T)
}


// MARK: - Context for mappable
struct ContextForMapFromRequest: MapContext {
    enum DtoType {
        case list
        case detail
        case page
    }
    
    var dtoType: DtoType
    
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
    func getList() -> AnyPublisher<[Entity], ApiError>
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<Entity, ApiError>
    func getObject(_ id: Entity.ID) -> AnyPublisher<Entity, ApiError>
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<Entity, ApiError>
    
    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<Entity, ApiError>
    
    // Delete methods
    func deleteObject(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError>
    
}

// MARK: - ObjectRequester ext
extension ObjectRequester {
    // URL getter
    func urlFor(_ requestType: RequestType<Entity.ID>) -> URL {
        var ans = host.appendingPathComponent(resource)
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
    
    // Helpers
    fileprivate func mapError(_ err: Error) -> ApiError {
        if let newErr = err as? URLRequester.RequestError {
            return ApiError.requestError(err: newErr)
        }
        if let newErr = err as? ApiError {
            return newErr
        }
        return ApiError.requestError(err: URLRequester.RequestError.unknown)
    }
    
    fileprivate func simpleTryMap(data: Data, dtoType: ContextForMapFromRequest.DtoType) throws -> Entity {
        let jsonString = String(data: data, encoding: .utf8)!
        guard let ans = Entity(JSONString: jsonString) else {
            throw ApiError.decodeError(type: Entity.self)
        }
        return ans
    }
    
    // Get methods
    func getList() -> AnyPublisher<[Entity], ApiError> {
        let url = urlFor(.getList)
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> [Entity] in
                let jsonString = String(data: data, encoding: .utf8)!
                let mapper = Mapper<Entity>()
                mapper.context = ContextForMapFromRequest(dtoType: .list)
                guard let ans = mapper.mapArray(JSONfile: jsonString) else {
                    throw ApiError.decodeError(type: Entity.self)
                }
                return ans
            }
            .mapError { (err) -> ApiError in
                return self.mapError(err)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.getPaginated(limit: limit, offset: offset))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data, dtoType: .page)
                return ans
                
            }
            .mapError { (err) -> ApiError in
                return self.mapError(err)
            }
            .eraseToAnyPublisher()
        return publisher
    }
    
    func getObject(_ id: Entity.ID) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.getObject(id: id))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.get()
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data, dtoType: .detail)
                return ans
            }
            .mapError { (err) -> ApiError in
                return self.mapError(err)
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
                let ans = try self.simpleTryMap(data: data, dtoType: .list)
                return ans
            }
            .mapError { (err) -> ApiError in
                return self.mapError(err)
            }
            .eraseToAnyPublisher()
        return publisher
    }

    // Patch methods
    func patchObject(_ id: Entity.ID, entity: Entity) -> AnyPublisher<Entity, ApiError> {
        let url = urlFor(.patchObject(id: id))
        let urlRequester = URLRequester(host: url)
        let publisher = urlRequester.patch()
            .tryMap { (data, _) -> Entity in
                let ans = try self.simpleTryMap(data: data, dtoType: .detail)
                return ans
            }
            .mapError { (err) -> ApiError in
                return self.mapError(err)
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
    
    var resource: String {
        "ratings"
    }
    
}


// MARK: - Accept requester
class AcceptRequester: ObjectRequester {
    typealias Entity = Accept
    
    var host: URL {
        Hosts.placesHostUrl
    }
    
    var resource: String {
        "accepts"
    }
    
}


// MARK: - PlaceImage requester
class PlaceImageRequester: ObjectRequester {
    typealias Entity = PlaceImage
    
    var host: URL {
        Hosts.awardsHostUrl
    }
    
    var resource: String {
        "place_images"
    }
    
}


// MARK: - Place requester
class PlaceRequester: ObjectRequester {
    typealias Entity = Place
    
    var host: URL {
        Hosts.awardsHostUrl
    }
    
    var resource: String {
        "places"
    }
    
}
