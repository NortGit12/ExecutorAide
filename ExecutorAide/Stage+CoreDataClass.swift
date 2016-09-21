//
//  Stage+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public class Stage: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "Stage"
    static let descriptorKey = "descriptor"
    static let nameKey = "name"
    static let percentCompleteKey = "percentComplete"
    static let sortValueKey = "sortValue"
    static let tasksKey = "tasks"
    static let testatorKey = "testator"
    
    var recordType: String { return Stage.type }
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Stage.descriptorKey] = self.descriptor as NSString
        record[Stage.nameKey] = self.name as NSString
        record[Stage.percentCompleteKey] = self.percentComplete as NSNumber
        record[Stage.sortValueKey] = self.sortValue as NSNumber
        
        var tasksReferencesArray = [CKReference]()
        if let tasks = self.tasks {
            
            if tasks.count > 0 {
                
                for task in tasks {
                    
                    guard let task = task as? Task
                        , let recordIDData = task.recordIDData as? Data
                        , let recordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
                        else { continue }
                    
                    let taskReference = CKReference(recordID: recordID, action: .deleteSelf)
                    tasksReferencesArray.append(taskReference)
                }
                
                record[Stage.tasksKey] = tasksReferencesArray as NSArray
            } else {
                
                record[Stage.tasksKey] = [Task]() as NSArray
            }
        }
        
        guard let recordIDData = self.testator.recordIDData as? Data
            , let testatorRecordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
            else {
                
                print("Error: Could not unarchive the Testator's recordIDData when attempting to compute the cloudKitRecord for a Stage.")
                return nil
        }
        
        let testatorReference = CKReference(recordID: testatorRecordID, action: .deleteSelf)
        record[Stage.testatorKey] = testatorReference as CKReference
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(descriptor: String, name: String, percentComplete: Float = 0.0, sortValue: Int, tasks: [Task]? = nil, testator: Testator, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let stageEntity = NSEntityDescription.entity(forEntityName: Stage.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(Stage.type).")
            return nil
        }
        
        self.init(entity: stageEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.name = name
        self.percentComplete = percentComplete
        self.recordName = nameForManagedObject()
        self.sortValue = sortValue
        
        let tasksMutableOrderedSet = NSMutableOrderedSet()
        if let tasks = tasks {
            for task in tasks {
                tasksMutableOrderedSet.add(task)
            }
            self.tasks = NSOrderedSet(orderedSet: tasksMutableOrderedSet)
        }
        
        self.testator = testator
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let descriptor = record[Stage.descriptorKey] as? String
            , let name = record[Stage.nameKey] as? String
            , let percentComplete = record[Stage.percentCompleteKey] as? Float
            , let sortValue = record[Stage.sortValueKey] as? Int
            , let testatorReference = record[Stage.testatorKey] as? CKReference
            else {
                
                print("Error: Could not create the \(Stage.type) from the CloudKit record.")
                return nil
            }
        
        guard let stageEntity = NSEntityDescription.entity(forEntityName: Stage.type, in: context) else {
        
            print("Error: \(Stage.type) entity could not be created when creating an instance from a CloudKit record.")
            return nil
        }
        
        self.init(entity: stageEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        self.percentComplete = percentComplete
        self.sortValue = sortValue
        
        if let tasksReferences = record[Task.subTasksKey] as? [CKReference] {
            
            let tasks = setTasks(tasksReferences: tasksReferences)
            
            self.tasks = NSOrderedSet(array: tasks)
        }
        
        let testatorIDName = testatorReference.recordID.recordName
        guard let testator = TestatorModelController.shared.fetchTestatorByIDName(idName: testatorIDName) else {
            
            print("Error: Could not identify the testator by its ID name \"\(testatorIDName)\".")
            return nil
        }
        
        self.testator = testator
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setTasks(tasksReferences: [CKReference]) -> [Task] {
        
        var tasks = [Task]()
        for taskReference in tasksReferences {
            
            let taskIDName = taskReference.recordID.recordName
            if let task = TaskModelController.shared.fetchTaskByIDName(idName: taskIDName) {
                
                tasks.append(task)
            }
        }
        
        return tasks
    }

}
























