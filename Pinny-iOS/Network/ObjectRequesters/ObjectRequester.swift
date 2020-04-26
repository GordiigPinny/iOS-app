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
enum RequestType {
    case getList
    case getPaginated(limit: UInt, offset: UInt)
    case getObject(id: UInt)
    case postObject
    case patchObject(id: UInt)
    case deleteObject(id: UInt)
}


// MARK: - ObjectRequester protocol
protocol ObjectRequester {
    // Types
    associatedtype Entity: ConvertableToDto
    typealias ListDto = Entity.ListDto
    typealias DetailDto = Entity.DetailDto
    typealias PgDto = Entity.PgDto
    
    // Variables
    var host: URL { get }
    func urlFor(_ requestType: RequestType) -> URL
    
    // Get methods
    func getList() -> AnyPublisher<[ListDto], ApiError>
    func getPaginated(limit: UInt, offset: UInt) -> AnyPublisher<PgDto, ApiError>
    func getObject(_ id: UInt) -> AnyPublisher<DetailDto, ApiError>
    
    // Post methods
    func postObject(entity: Entity) -> AnyPublisher<ListDto, ApiError>
    func postObject(dto: DetailDto) -> AnyPublisher<ListDto, ApiError>
    
    // Patch methods
    func patchObject(_ id: UInt, entity: Entity) -> AnyPublisher<DetailDto, ApiError>
    func patchObject(_ id: UInt, dto: DetailDto) -> AnyPublisher<DetailDto, ApiError>
    
    // Delete methods
    func deleteObject(_ id: UInt) -> AnyPublisher<Bool, ApiError>
    
}

// MARK: - ObjectRequester ext
extension ObjectRequester {
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
    
    func getObject(_ id: UInt) -> AnyPublisher<DetailDto, ApiError> {
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
    func patchObject(_ id: UInt, entity: Entity) -> AnyPublisher<DetailDto, ApiError> {
        return patchObject(id, dto: entity.toDetailDto())
    }
    
    func patchObject(_ id: UInt, dto: DetailDto) -> AnyPublisher<DetailDto, ApiError> {
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
    func deleteObject(_ id: UInt) -> AnyPublisher<Bool, ApiError> {
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

