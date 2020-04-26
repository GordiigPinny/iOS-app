//
//  Accept+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension Accept {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Accept> {
        return NSFetchRequest<Accept>(entityName: "Accept")
    }

    @NSManaged public var id: Int64
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var place: Place?
    @NSManaged public var createdBy: User?

}
