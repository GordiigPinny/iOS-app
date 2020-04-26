//
//  Place+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var address: String?
    @NSManaged public var checkedByModerator: Bool
    @NSManaged public var createdDt: Date?
    @NSManaged public var deletedFlg: Bool
    @NSManaged public var pictures: NSSet?
    @NSManaged public var accepts: NSSet?
    @NSManaged public var ratings: NSSet?

}

// MARK: Generated accessors for pictures
extension Place {

    @objc(addPicturesObject:)
    @NSManaged public func addToPictures(_ value: PlaceImage)

    @objc(removePicturesObject:)
    @NSManaged public func removeFromPictures(_ value: PlaceImage)

    @objc(addPictures:)
    @NSManaged public func addToPictures(_ values: NSSet)

    @objc(removePictures:)
    @NSManaged public func removeFromPictures(_ values: NSSet)

}

// MARK: Generated accessors for accepts
extension Place {

    @objc(addAcceptsObject:)
    @NSManaged public func addToAccepts(_ value: Accept)

    @objc(removeAcceptsObject:)
    @NSManaged public func removeFromAccepts(_ value: Accept)

    @objc(addAccepts:)
    @NSManaged public func addToAccepts(_ values: NSSet)

    @objc(removeAccepts:)
    @NSManaged public func removeFromAccepts(_ values: NSSet)

}

// MARK: Generated accessors for ratings
extension Place {

    @objc(addRatingsObject:)
    @NSManaged public func addToRatings(_ value: Rating)

    @objc(removeRatingsObject:)
    @NSManaged public func removeFromRatings(_ value: Rating)

    @objc(addRatings:)
    @NSManaged public func addToRatings(_ values: NSSet)

    @objc(removeRatings:)
    @NSManaged public func removeFromRatings(_ values: NSSet)

}
