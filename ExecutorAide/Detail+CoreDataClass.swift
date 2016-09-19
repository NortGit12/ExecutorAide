//
//  Detail+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


public class Detail: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================

    static let type = "Detail"
    static let contentTypeKey = "contentType"
    static let contentValueKey = "contentValue"
    static let sortValueKey = "sortValue"
    static let subTaskKey = "subTask"
    
    var recordType: String { return Detail.type }
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: Detail.type, recordID: recordID)
        
        record[Detail.contentTypeKey] = self.contentType as CKRecordValue?
        record[Detail.contentValueKey] = self.contentValue as CKRecordValue?
        record[Detail.sortValueKey] = self.sortValue as CKRecordValue?
        
        guard let recordIDData = self.subTask.recordIDData as? Data
            , let subTaskRecordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
            else {
            
                NSLog("Error: Could not unarchive the recordIDData when attempting to compute the cloudKitRecord")
                return nil
            }
        
        let subTaskReference = CKReference(recordID: subTaskRecordID, action: .deleteSelf)
        record[Detail.subTaskKey] = subTaskReference
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(contentType: String, contentValue: String, sortValue: Int, subTask: SubTask, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let detailEntity = NSEntityDescription.entity(forEntityName: Detail.type, in: context) else {
            
            NSLog("Error: Could not create teh entity description for a \(Detail.type).")
            return nil
        }
        
        self.init(entity: detailEntity, insertInto: context)
        
        self.contentType = contentType
        self.contentValue = contentValue
        self.sortValue = sortValue
        self.subTask = subTask
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let contentType = record[Detail.contentTypeKey] as? String
            , let contentValue = record[Detail.contentValueKey] as? String
            , let sortValue = record[Detail.sortValueKey] as? Int
            , let subTaskReference = record[Detail.subTaskKey] as? CKReference
            else {
                
                NSLog("Error: Could not create the Detail from the CloudKit record.")
                return nil
            }
        
        guard let detailEntity = NSEntityDescription.entity(forEntityName: Detail.type, in: context) else {
            
            NSLog("Error: Could not create the entity description for a \(Detail.type).")
            return nil
        }
        
        self.init(entity: detailEntity, insertInto: context)
        
        self.contentType = contentType
        self.contentValue = contentValue
        self.sortValue = sortValue
        
        let subTaskIDName = subTaskReference.recordID.recordName
        guard let subTask = SubTaskModelController.shared.fetchSubTaskByIDName(idName: subTaskIDName) else {
            
            NSLog("Error: Could not identify the SubTask by its ID name \"\(subTaskIDName)\".")
            return nil
        }
        
        self.subTask = subTask
    }
}























