//
//  User+CoreDataProperties.swift
//  
//
//  Created by Dmitry Gorin on 26.04.2020.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: Int64
    @NSManaged public var username: String?
    @NSManaged public var email: String?
    @NSManaged public var rating: Int32
    @NSManaged public var money: Int32
    @NSManaged public var createdDt: Date?
    @NSManaged public var profileId: Int64
    @NSManaged public var uploadedImages: NSSet?
    @NSManaged public var unlockedPins: NSSet?
    @NSManaged public var achievements: NSSet?
    @NSManaged public var avatar: ImageFile?
    @NSManaged public var pinSprite: Pin?
    @NSManaged public var geopinSprite: Pin?

}

// MARK: Generated accessors for uploadedImages
extension User {

    @objc(addUploadedImagesObject:)
    @NSManaged public func addToUploadedImages(_ value: ImageFile)

    @objc(removeUploadedImagesObject:)
    @NSManaged public func removeFromUploadedImages(_ value: ImageFile)

    @objc(addUploadedImages:)
    @NSManaged public func addToUploadedImages(_ values: NSSet)

    @objc(removeUploadedImages:)
    @NSManaged public func removeFromUploadedImages(_ values: NSSet)

}

// MARK: Generated accessors for unlockedPins
extension User {

    @objc(addUnlockedPinsObject:)
    @NSManaged public func addToUnlockedPins(_ value: Pin)

    @objc(removeUnlockedPinsObject:)
    @NSManaged public func removeFromUnlockedPins(_ value: Pin)

    @objc(addUnlockedPins:)
    @NSManaged public func addToUnlockedPins(_ values: NSSet)

    @objc(removeUnlockedPins:)
    @NSManaged public func removeFromUnlockedPins(_ values: NSSet)

}

// MARK: Generated accessors for achievements
extension User {

    @objc(addAchievementsObject:)
    @NSManaged public func addToAchievements(_ value: Achievement)

    @objc(removeAchievementsObject:)
    @NSManaged public func removeFromAchievements(_ value: Achievement)

    @objc(addAchievements:)
    @NSManaged public func addToAchievements(_ values: NSSet)

    @objc(removeAchievements:)
    @NSManaged public func removeFromAchievements(_ values: NSSet)

}
