//
//  PlaceImage+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension PlaceImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceImage> {
        return NSFetchRequest<PlaceImage>(entityName: "PlaceImage")
    }

    @NSManaged public var id: Int64
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var place: Place?
    @NSManaged public var createdBy: User?
    @NSManaged public var imageFile: ImageFile?

}
