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
    static let taskKey = "task"
    
    var recordType: String { return SubTask.type }
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: SubTask.type, recordID: recordID)
        
        var detailsReferences = [CKReference]()
        if let details = self.details {
            
            if details.count > 0 {
                for detail in details {
                    
                    guard let detail = detail as? Detail
                        , let recordIDData = detail.recordIDData as? Data
                        , let recordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
                        else { continue }
                    
                    let detailReference = CKReference(recordID: recordID, action: .deleteSelf)
                    detailsReferences.append(detailReference)
                }
            }
        }
        
        record[SubTask.detailsKey] = detailsReferences as CKRecordValue?
        
        record[SubTask.isCompletedKey] = self.isCompleted as CKRecordValue?
        record[SubTask.nameKey] = self.name as CKRecordValue?
        
        guard let recordIDData = self.task.recordIDData as? Data
            , let taskRecordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
            else {
                
                NSLog("Error: Could not unarchive the recordIDData when attempting to compute the cloudKitRecord for a SubTask.")
                return nil
        }
        
        let taskReference = CKReference(recordID: taskRecordID, action: .deleteSelf)
        record[SubTask.taskKey] = taskReference
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================

    convenience init?(name: String, descriptor: String, isCompleted: Bool = false, task: Task, details: [Detail]?, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let subTaskEntity = NSEntityDescription.entity(forEntityName: SubTask.type, in: context) else {
            
            NSLog("Error: Could not create teh entity description for a \(SubTask.type).")
            return nil
        }
        
        self.init(entity: subTaskEntity, insertInto: context)
        
        self.descriptor = descriptor
        
        let detailssMutableOrderedSet = NSMutableOrderedSet()
        if let details = details {
            
            for detail in details {
                
                detailssMutableOrderedSet.add(detail)
            }
            
            self.details = NSOrderedSet(set: detailssMutableOrderedSet.copy() as! Set<AnyHashable>)
        }
        
        self.isCompleted = isCompleted
        self.name = name
        self.recordName = nameForManagedObject()
        self.task = task
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let descriptor = record[SubTask.descriptorKey] as? String
            , let isCompleted = record[SubTask.isCompletedKey] as? Bool
            , let name = record[SubTask.nameKey] as? String
            , let taskReference = record[SubTask.taskKey] as? CKReference
            else {
                
                NSLog("Error: Could not create the Task from the CloudKit record.")
                return nil
            }
        
        guard let subTaskEntity = NSEntityDescription.entity(forEntityName: SubTask.type, in: context) else {
            
            NSLog("Error: Could not create the entity description for a \(SubTask.type).")
            return nil
        }
        
        self.init(entity: subTaskEntity, insertInto: context)
        
        self.descriptor = descriptor
        
        if let detailsReferences = record[SubTask.detailsKey] as? [CKReference] {
            
            let details = setDetails(detailsReferences: detailsReferences)
            
            self.details = NSOrderedSet(array: details)
        }
        
        self.isCompleted = isCompleted
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        
        let taskIDName = taskReference.recordID.recordName
        guard let task = TaskModelController.shared.fetchTaskByIDName(taskIDName) else {
            
            NSLog("Error: Could not identify the stage by its ID name \"\(taskIDName)\".")
            return nil
        }

        self.task = task
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setDetails(detailsReferences: [CKReference]) -> [Detail] {
        
        var details = [Detail]()
        for detailReferences in detailsReferences {
            
            let detailIDName = detailReferences.recordID.recordName
            if let detail = DetailModelController.shared.fetchDetailByIDName(detailIDName) {
                
                details.append(detail)
            }
        }
        
        return details
    }
}


























