//
//  CoreDataStack.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    // MARK: - Singletone work
    private static var _instance: CoreDataStack?
    private init() {
        
    }
    class var instance: CoreDataStack {
        if _instance == nil {
            _instance = CoreDataStack()
        }
        return _instance!
    }
    
    // MARK: - Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Pinny_iOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Context
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
