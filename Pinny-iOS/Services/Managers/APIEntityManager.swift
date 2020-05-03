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
    func fetch(id: Entity.ID, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?)
    func filter<T: Equatable>(_ keyPath: KeyPath<Entity, T>, equalsTo value: T) -> Self

    func exists(id: Entity.ID) -> Bool
    func exists(_ entity: Entity) -> Bool

    func create(_ entity: Entity, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?)
    func update(_ id: Entity.ID, _ entity: Entity, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?)
    func addLocaly(_ entity: Entity)
    func replace(_ id: Entity.ID, with newEntity: Entity)
    func replace(_ entity: Entity, with newEntity: Entity)
   
    func delete(_ id: Entity.ID)
    func delete(_ entity: Entity)
    
    func deleteRemotely(_ id: Entity.ID, onSuccess: ((Bool) -> Void)?, onError: ((ApiError) -> Void)?)
    func deleteRemotely(_ entity: Entity, onSuccess: ((Bool) -> Void)?, onError: ((ApiError) -> Void)?)
    
    func checkEntityWithKeyPath<T: Equatable>(_ entity: Entity, keyPath: KeyPath<Entity, T>, value: T) -> Bool
    
}


// MARK: - Default implementation
extension APIEntityManager {
    // Geting entities
    func get(id: Entity.ID) -> Entity? {
        let filtered = filter(\Entity.id, equalsTo: id).entities
        return filtered.first
    }
    
    func fetch(id: Entity.ID, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?) {
        let _ = self.requester.getObject(id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    onError?(err)
                case .finished:
                    break
                }
            }) { newEntity in
                self.replace(newEntity, with: newEntity)
                onSuccess?(newEntity)
            }
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
    func create(_ entity: Entity, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?) {
        let _ = requester.postObject(entity: entity)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .failure(let err):
                    onError?(err)
                case .finished:
                    break
                }
            }) { newEntity in
                self.replace(newEntity, with: newEntity)
                onSuccess?(newEntity)
            }
    }
    
    func update(_ id: Entity.ID, _ entity: Entity, onSuccess: ((Entity) -> Void)?, onError: ((ApiError) -> Void)?) {
        let _ = requester.patchObject(id, entity: entity)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    onError?(err)
                case .finished:
                    break
                }
            }) { newEntity in
                self.replace(newEntity, with: newEntity)
                onSuccess?(newEntity)
            }
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
    func deleteRemotely(_ id: Entity.ID, onSuccess: ((Bool) -> Void)?, onError: ((ApiError) -> Void)?) {
        let _ = requester.deleteObject(id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    onError?(err)
                case .finished:
                    break
                }
            }) { didDelete in
                if didDelete {
                    self.delete(id)
                }
                onSuccess?(didDelete)
            }
    }
    
    func deleteRemotely(_ entity: Entity, onSuccess: ((Bool) -> Void)?, onError: ((ApiError) -> Void)?) {
        guard let id = entity.id else {
            return
        }
        deleteRemotely(id, onSuccess: onSuccess, onError: onError)
    }
    
}
