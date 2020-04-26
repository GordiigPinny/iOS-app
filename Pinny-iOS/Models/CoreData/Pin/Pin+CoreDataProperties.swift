//
//  Pin+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var descr: String?
    @NSManaged public var pTypeAsString: String?
    @NSManaged public var price: Int32
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var picture: ImageFile?

}
