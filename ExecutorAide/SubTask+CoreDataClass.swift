//
//  SubTask+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


public class SubTask: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "SubTask"
    static let descriptorKey = "descriptor"
    static let detailsKey = "details"
    static let isCompletedKey = "isCompleted"
    static let nameKey = "name"
    static let sortValueKey = "sortValue"
    static let taskKey = "task"
    
    var recordType: String { return SubTask.type }
    
    var cloudKitRecord: CKRecord? {
        
        var record = CKRecord(recordType: SubTask.type)
        PersistenceController.shared.moc.performAndWait {
            
            let recordID = CKRecordID(recordName: self.recordName)
            record = CKRecord(recordType: self.recordType, recordID: recordID)
            
            if let descriptor = self.descriptor {
                
                record[SubTask.descriptorKey] = descriptor as NSString
            }
            
            record[SubTask.isCompletedKey] = self.isCompleted as NSNumber
            record[SubTask.nameKey] = self.name as NSString
            record[SubTask.sortValueKey] = self.sortValue as NSNumber
            
            guard let taskCloudKitRecord = self.task.cloudKitRecord
                else {
                    print("Error: Could not unarchive the Task's recordID when attempting to compute the cloudKitRecord for a SubTask.")
                    return
            }
            
            let taskRecordID = taskCloudKitRecord["recordID"] as! CKRecordID
            let taskReference = CKReference(recordID: taskRecordID, action: .deleteSelf)
            record[SubTask.taskKey] = taskReference as CKReference
        }
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================

    convenience init?(descriptor: String?, isCompleted: Bool = false, name: String, sortValue: Int, task: Task, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let subTaskEntity = NSEntityDescription.entity(forEntityName: SubTask.type, in: context) else {
            
            print("Error: Could not create teh entity description for a \(SubTask.type).")
            return nil
        }
        
        self.init(entity: subTaskEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.isCompleted = isCompleted
        self.name = name
        self.recordName = nameForManagedObject()
        self.sortValue = sortValue
        self.task = task
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let descriptor = record[SubTask.descriptorKey] as? String
            , let isCompleted = record[SubTask.isCompletedKey] as? Bool
            , let name = record[SubTask.nameKey] as? String
            , let sortValue = record[SubTask.sortValueKey] as? Int
            , let taskReference = record[SubTask.taskKey] as? CKReference
            else {
                
                print("Error: Could not create the Task from the CloudKit record.")
                return nil
            }
        
        guard let subTaskEntity = NSEntityDescription.entity(forEntityName: SubTask.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(SubTask.type).")
            return nil
        }
        
        self.init(entity: subTaskEntity, insertInto: context)
        
        self.descriptor = descriptor
        self.isCompleted = isCompleted
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        self.sortValue = sortValue
        
        let taskIDName = taskReference.recordID.recordName
        guard let task = TaskModelController.shared.fetchTaskByIDName(idName: taskIDName) else {
            
            print("Error: Could not identify the Task by its ID name \"\(taskIDName)\".")
            return nil
        }

        self.task = task
    }
}


























