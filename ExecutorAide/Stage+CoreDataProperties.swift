//
//  Stage+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData


extension Stage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stage> {
        return NSFetchRequest<Stage>(entityName: "Stage");
    }

    @NSManaged public var descriptor: String?
    @NSManaged public var name: String?
    @NSManaged public var percentComplete: Float
    @NSManaged public var tasks: NSOrderedSet?
    @NSManaged public var testators: NSOrderedSet?

}

// MARK: Generated accessors for tasks
extension Stage {

    @objc(insertObject:inTasksAtIndex:)
    @NSManaged public func insertIntoTasks(_ value: Task, at idx: Int)

    @objc(removeObjectFromTasksAtIndex:)
    @NSManaged public func removeFromTasks(at idx: Int)

    @objc(insertTasks:atIndexes:)
    @NSManaged public func insertIntoTasks(_ values: [Task], at indexes: NSIndexSet)

    @objc(removeTasksAtIndexes:)
    @NSManaged public func removeFromTasks(at indexes: NSIndexSet)

    @objc(replaceObjectInTasksAtIndex:withObject:)
    @NSManaged public func replaceTasks(at idx: Int, with value: Task)

    @objc(replaceTasksAtIndexes:withTasks:)
    @NSManaged public func replaceTasks(at indexes: NSIndexSet, with values: [Task])

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSOrderedSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSOrderedSet)

}

// MARK: Generated accessors for testators
extension Stage {

    @objc(insertObject:inTestatorsAtIndex:)
    @NSManaged public func insertIntoTestators(_ value: Testator, at idx: Int)

    @objc(removeObjectFromTestatorsAtIndex:)
    @NSManaged public func removeFromTestators(at idx: Int)

    @objc(insertTestators:atIndexes:)
    @NSManaged public func insertIntoTestators(_ values: [Testator], at indexes: NSIndexSet)

    @objc(removeTestatorsAtIndexes:)
    @NSManaged public func removeFromTestators(at indexes: NSIndexSet)

    @objc(replaceObjectInTestatorsAtIndex:withObject:)
    @NSManaged public func replaceTestators(at idx: Int, with value: Testator)

    @objc(replaceTestatorsAtIndexes:withTestators:)
    @NSManaged public func replaceTestators(at indexes: NSIndexSet, with values: [Testator])

    @objc(addTestatorsObject:)
    @NSManaged public func addToTestators(_ value: Testator)

    @objc(removeTestatorsObject:)
    @NSManaged public func removeFromTestators(_ value: Testator)

    @objc(addTestators:)
    @NSManaged public func addToTestators(_ values: NSOrderedSet)

    @objc(removeTestators:)
    @NSManaged public func removeFromTestators(_ values: NSOrderedSet)

}
