//
//  APIEntityManager.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 28.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine


// MARK: - Protocol
protocol APIEntityManager: class {
    associatedtype Entity: APIEntity
    associatedtype Requester: ObjectRequester where Requester.Entity == Self.Entity
    typealias ApiError = Requester.ApiError
    
    static var instance: Self { get }
    
    var entities: [Entity] { get set }
    var requester: Requester { get }
    
    func get(id: Entity.ID) -> Entity?
    func fetch(id: Entity.ID) -> AnyPublisher<Entity, ApiError>
    func filter<T: Equatable>(_ keyPath: KeyPath<Entity, T>, equalsTo value: T) -> Self

    func exists(id: Entity.ID) -> Bool
    func exists(_ entity: Entity) -> Bool

    func create(_ entity: Entity) -> AnyPublisher<Entity, ApiError>
    func update(_ id: Entity.ID, _ entity: Entity) -> AnyPublisher<Entity, ApiError>
    func addLocaly(_ entity: Entity)
    func replace(_ id: Entity.ID, with newEntity: Entity)
    func replace(_ entity: Entity, with newEntity: Entity)
   
    func delete(_ id: Entity.ID)
    func delete(_ entity: Entity)
    
    func deleteRemotely(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError>
    func deleteRemotely(_ entity: Entity) -> AnyPublisher<Bool, ApiError>
    
    func checkEntityWithKeyPath<T: Equatable>(_ entity: Entity, keyPath: KeyPath<Entity, T>, value: T) -> Bool
    
}


// MARK: - Default implementation
extension APIEntityManager {
    // Geting entities
    func get(id: Entity.ID) -> Entity? {
        let filtered = filter(\Entity.id, equalsTo: id).entities
        return filtered.first
    }
    
    func fetch(id: Entity.ID) -> AnyPublisher<Entity, ApiError> {
        let ans = self.requester.getObject(id)
            .map { entity -> Entity in
                self.replace(entity, with: entity)
                return entity
            }
            .eraseToAnyPublisher()
        return ans
    }
    
    func filter<T: Equatable>(_ keyPath: KeyPath<Entity, T>, equalsTo value: T) -> Self {
        let newManager = self
        newManager.entities = newManager.entities.filter { checkEntityWithKeyPath($0, keyPath: keyPath, value: value) }
        return newManager
    }

    // Existence check
    func exists(id: Entity.ID) -> Bool {
        self.entities.contains { $0.id == id  }
    }

    func exists(_ entity: Entity) -> Bool {
        entity.id == nil ? false : self.exists(id: entity.id!)
    }

    // Creating and updating entities
    func create(_ entity: Entity) -> AnyPublisher<Entity, ApiError> {
        let ans = requester.postObject(entity: entity)
            .map { newEntity -> Entity in
                self.replace(newEntity, with: newEntity)
                return newEntity
            }
            .eraseToAnyPublisher()
        return ans
    }
    
    func update(_ id: Entity.ID, _ entity: Entity) -> AnyPublisher<Entity, ApiError> {
        let ans = requester.patchObject(id, entity: entity)
            .map { newEntity -> Entity in
                self.replace(newEntity, with: newEntity)
                return entity
            }
            .eraseToAnyPublisher()
        return ans
    }
    
    func addLocaly(_ entity: Entity) {
        if entity.id != nil && !exists(entity) {
            entities.append(entity)
        }
    }
    
    func replace(_ id: Entity.ID, with newEntity: Entity) {
        entities.removeAll { $0.id == id }
        entities.append(newEntity)
    }
    
    func replace(_ entity: Entity, with newEntity: Entity) {
        guard let id = entity.id else {
            return
        }
        replace(id, with: newEntity)
    }
    
    // Deleting locally
    func delete(_ id: Entity.ID) {
        entities.removeAll { $0.id == id }
    }
    
    func delete(_ entity: Entity) {
        guard let id = entity.id else {
            return
        }
        delete(id)
    }
    
    // Deleting remotely
    func deleteRemotely(_ id: Entity.ID) -> AnyPublisher<Bool, ApiError> {
        let ans = requester.deleteObject(id)
            .map { didDelete -> Bool in
                if didDelete {
                    self.delete(id)
                }
                return didDelete
            }
            .eraseToAnyPublisher()
        return ans
    }
    
    func deleteRemotely(_ entity: Entity) -> AnyPublisher<Bool, ApiError> {
        guard let id = entity.id else {
            return Future<Bool, ApiError> { promise in
                return promise(.success(false))
            }.eraseToAnyPublisher()
        }
        return deleteRemotely(id)
    }
    
}
