//
//  ImageFile+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension ImageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageFile> {
        return NSFetchRequest<ImageFile>(entityName: "ImageFile")
    }

    @NSManaged public var id: Int64
    @NSManaged public var image: Data?
    @NSManaged public var objectId: Int64
    @NSManaged public var objectType: String?
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var createdBy: User?

}
