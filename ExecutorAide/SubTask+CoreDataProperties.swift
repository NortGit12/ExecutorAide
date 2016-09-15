//
//  SubTask+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import 

extension SubTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubTask> {
        return NSFetchRequest<SubTask>(entityName: "SubTask");
    }

    @NSManaged public var descriptor: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String
    @NSManaged public var details: NSOrderedSet?
    @NSManaged public var task: Task

}

// MARK: Generated accessors for details
extension SubTask {

    @objc(insertObject:inDetailsAtIndex:)
    @NSManaged public func insertIntoDetails(_ value: Detail, at idx: Int)

    @objc(removeObjectFromDetailsAtIndex:)
    @NSManaged public func removeFromDetails(at idx: Int)

    @objc(insertDetails:atIndexes:)
    @NSManaged public func insertIntoDetails(_ values: [Detail], at indexes: NSIndexSet)

    @objc(removeDetailsAtIndexes:)
    @NSManaged public func removeFromDetails(at indexes: NSIndexSet)

    @objc(replaceObjectInDetailsAtIndex:withObject:)
    @NSManaged public func replaceDetails(at idx: Int, with value: Detail)

    @objc(replaceDetailsAtIndexes:withDetails:)
    @NSManaged public func replaceDetails(at indexes: NSIndexSet, with values: [Detail])

    @objc(addDetailsObject:)
    @NSManaged public func addToDetails(_ value: Detail)

    @objc(removeDetailsObject:)
    @NSManaged public func removeFromDetails(_ value: Detail)

    @objc(addDetails:)
    @NSManaged public func addToDetails(_ values: NSOrderedSet)

    @objc(removeDetails:)
    @NSManaged public func removeFromDetails(_ values: NSOrderedSet)

}
