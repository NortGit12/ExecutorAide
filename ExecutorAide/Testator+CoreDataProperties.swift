//
//  Testator+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData


extension Testator {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Testator> {
        return NSFetchRequest<Testator>(entityName: "Testator");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var name: String
    @NSManaged public var sortValue: Int
    @NSManaged public var stages: NSOrderedSet

}

// MARK: Generated accessors for stages
extension Testator {

    @objc(insertObject:inStagesAtIndex:)
    @NSManaged public func insertIntoStages(_ value: Stage, at idx: Int)

    @objc(removeObjectFromStagesAtIndex:)
    @NSManaged public func removeFromStages(at idx: Int)

    @objc(insertStages:atIndexes:)
    @NSManaged public func insertIntoStages(_ values: [Stage], at indexes: NSIndexSet)

    @objc(removeStagesAtIndexes:)
    @NSManaged public func removeFromStages(at indexes: NSIndexSet)

    @objc(replaceObjectInStagesAtIndex:withObject:)
    @NSManaged public func replaceStages(at idx: Int, with value: Stage)

    @objc(replaceStagesAtIndexes:withStages:)
    @NSManaged public func replaceStages(at indexes: NSIndexSet, with values: [Stage])

    @objc(addStagesObject:)
    @NSManaged public func addToStages(_ value: Stage)

    @objc(removeStagesObject:)
    @NSManaged public func removeFromStages(_ value: Stage)

    @objc(addStages:)
    @NSManaged public func addToStages(_ values: NSOrderedSet)

    @objc(removeStages:)
    @NSManaged public func removeFromStages(_ values: NSOrderedSet)

}
