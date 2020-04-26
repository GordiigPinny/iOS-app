//
//  Achievement+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var descr: String?
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var picture: ImageFile?

}
