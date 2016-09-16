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
    static let tasksKey = "tasks"
    static let testatorsKey = "testators"
    
    var recordType: String { return Stage.type }
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Stage.descriptorKey] = self.descriptor as? CKRecordValue
        record[Stage.nameKey] = self.name as? CKRecordValue
        record[Stage.percentCompleteKey] = self.percentComplete as CKRecordValue?
        
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
                
                record[Stage.tasksKey] = tasksReferencesArray as CKRecordValue?
            }
        }
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(name: String, descriptor: String, percentComplete: Float = 0.0, tasks: [Task]?, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let stageEntity = NSEntityDescription.entity(forEntityName: Stage.type, in: context) else {
            
            NSLog("Error: Could not create the entity description for a \(Stage.type).")
            return nil
        }
        
        self.init(entity: stageEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.name = name
        self.percentComplete = percentComplete
        self.recordName = nameForManagedObject()
        
        let tasksMutableOrderedSet = NSMutableOrderedSet()
        if let tasks = tasks {
            
            for task in tasks {
                
                tasksMutableOrderedSet.add(task)
            }
            
            self.tasks = NSOrderedSet(set: tasksMutableOrderedSet.copy() as! Set<AnyHashable>)
        }
        
        // The maintenance of self.testators will be managed by Core Data as it manages the "stages" relationship in the Testators entity.
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let descriptor = record[Stage.descriptorKey] as? String
            , let name = record[Stage.nameKey] as? String
            , let percentComplete = record[Stage.percentCompleteKey] as? Float
            else {
                
                NSLog("Error: Could not create the \(Stage.type) from the CloudKit record.")
                return nil
            }
        
        guard let stageEntity = NSEntityDescription.entity(forEntityName: Stage.type, in: context) else {
        
            NSLog("Error: \(Stage.type) entity could not be created when creating an instance from a CloudKit record.")
            return nil
        }
        
        self.init(entity: stageEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        self.percentComplete = percentComplete
    }
}
























