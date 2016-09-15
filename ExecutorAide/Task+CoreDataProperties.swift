//
//  Task+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var name: String
    @NSManaged public var stage: Stage
    @NSManaged public var subTasks: NSOrderedSet?

}

//==================================================
// MARK: - Generated accessors for subTasks
//==================================================

extension Task {

    @objc(insertObject:inSubTasksAtIndex:)
    @NSManaged public func insertIntoSubTasks(_ value: SubTask, at idx: Int)

    @objc(removeObjectFromSubTasksAtIndex:)
    @NSManaged public func removeFromSubTasks(at idx: Int)

    @objc(insertSubTasks:atIndexes:)
    @NSManaged public func insertIntoSubTasks(_ values: [SubTask], at indexes: NSIndexSet)

    @objc(removeSubTasksAtIndexes:)
    @NSManaged public func removeFromSubTasks(at indexes: NSIndexSet)

    @objc(replaceObjectInSubTasksAtIndex:withObject:)
    @NSManaged public func replaceSubTasks(at idx: Int, with value: SubTask)

    @objc(replaceSubTasksAtIndexes:withSubTasks:)
    @NSManaged public func replaceSubTasks(at indexes: NSIndexSet, with values: [SubTask])

    @objc(addSubTasksObject:)
    @NSManaged public func addToSubTasks(_ value: SubTask)

    @objc(removeSubTasksObject:)
    @NSManaged public func removeFromSubTasks(_ value: SubTask)

    @objc(addSubTasks:)
    @NSManaged public func addToSubTasks(_ values: NSOrderedSet)

    @objc(removeSubTasks:)
    @NSManaged public func removeFromSubTasks(_ values: NSOrderedSet)

}
