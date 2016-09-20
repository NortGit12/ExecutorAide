//
//  Task+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


public class Task: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "Task"
    static let nameKey = "name"
    static let sortValueKey = "sortValue"
    static let stageKey = "stage"
    static let subTasksKey = "subTasks"
    
    var recordType: String { return Task.type }
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Task.nameKey] = self.name as CKRecordValue
        record[Task.sortValueKey] = self.sortValue as CKRecordValue?
        
        guard let recordIDData = self.stage.recordIDData as? Data
            , let stageRecordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
            else {
        
            print("Error: Could not unarchive the recordIDData when attempting to compute the cloudKitRecord for a Task.")
            return nil
        }
        
        let stageReference = CKReference(recordID: stageRecordID, action: .deleteSelf)
        record[Task.stageKey] = stageReference
        
        var subTasksReferences = [CKReference]()
        if let subTasks = self.subTasks {
            
            if subTasks.count > 0 {
                for subTask in subTasks {
                    
                    guard let subTask = subTask as? SubTask
                        , let recordIDData = subTask.recordIDData as? Data
                        , let recordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
                        else { continue }
                    
                    let subTaskReference = CKReference(recordID: recordID, action: .deleteSelf)
                    subTasksReferences.append(subTaskReference)
                }
            }
        }
        
        record[Task.subTasksKey] = subTasksReferences as CKRecordValue?
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================

    convenience init?(name: String, sortValue: Int, stage: Stage, subTasks: [SubTask]?, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let taskEntity = NSEntityDescription.entity(forEntityName: Task.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(Task.type).")
            return nil
        }
        
        self.init(entity: taskEntity, insertInto: context)
        
        self.name = name
        self.recordName = nameForManagedObject()
        self.sortValue = sortValue
        self.stage = stage
        
        let subTasksMutableOrderedSet = NSMutableOrderedSet()
        if let subTasks = subTasks {
        
            for subTask in subTasks {
                
                subTasksMutableOrderedSet.add(subTask)
            }
            
            self.subTasks = NSOrderedSet(orderedSet: subTasksMutableOrderedSet)
        }
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let name = record[Task.nameKey] as? String
            , let sortValue = record[Task.sortValueKey] as? Int
            , let stageReference = record[Task.stageKey] as? CKReference
            else {
            
                print("Error: Could not create the Task from the CloudKit record.")
                return nil
            }
        
        guard let taskEntity = NSEntityDescription.entity(forEntityName: Task.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(Task.type).")
            return nil
        }
        
        self.init(entity: taskEntity, insertInto: context)
        
        if let subTasksReferences = record[Task.subTasksKey] as? [CKReference] {
            
            let subTasks = setSubTasks(subTasksReferences: subTasksReferences)
            
            self.subTasks = NSOrderedSet(array: subTasks)
        }
        
        self.name = name
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.sortValue = sortValue
        
        let stageIDName = stageReference.recordID.recordName
        guard let stage = StageModelController.shared.fetchStageByIDName(idName: stageIDName) else {
            
            print("Error: Could not identify the stage by its ID name \"\(stageIDName)\".")
            return nil
        }
        
        self.stage = stage
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setSubTasks(subTasksReferences: [CKReference]) -> [SubTask] {
        
        var subTasks = [SubTask]()
        for subTaskReference in subTasksReferences {
            
            let subTaskIDName = subTaskReference.recordID.recordName
            if let subTask = SubTaskModelController.shared.fetchSubTaskByIDName(idName: subTaskIDName) {
                
                subTasks.append(subTask)
            }
        }
        
        return subTasks
    }
}






















