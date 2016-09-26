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
        
        var record = CKRecord(recordType: Detail.type)
        PersistenceController.shared.moc.performAndWait {
            
            let recordID = CKRecordID(recordName: self.recordName)
            record = CKRecord(recordType: self.recordType, recordID: recordID)
            
            record[Detail.contentTypeKey] = self.contentType as NSString
            record[Detail.contentValueKey] = self.contentValue as NSString
            record[Detail.sortValueKey] = self.sortValue as NSNumber
            
            guard let subTaskCloudKitRecord = self.subTask.cloudKitRecord
                else {
                    print("Error: Could not unarchive the SubTask's recordID when attempting to compute the cloudKitRecord for a Detail.")
                    return
            }
            
            let subTaskRecordID = subTaskCloudKitRecord["recordID"] as! CKRecordID
            let subTaskReference = CKReference(recordID: subTaskRecordID, action: .deleteSelf)
            record[Detail.subTaskKey] = subTaskReference as CKReference
        }
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(contentType: String, contentValue: String, sortValue: Int, subTask: SubTask, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let detailEntity = NSEntityDescription.entity(forEntityName: Detail.type, in: context) else {
            
            print("Error: Could not create teh entity description for a \(Detail.type).")
            return nil
        }
        
        self.init(entity: detailEntity, insertInto: context)
        
        self.contentType = contentType
        self.contentValue = contentValue
        self.recordName = nameForManagedObject()
        self.sortValue = sortValue
        self.subTask = subTask
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let contentType = record[Detail.contentTypeKey] as? String
            , let contentValue = record[Detail.contentValueKey] as? String
            , let sortValue = record[Detail.sortValueKey] as? Int
            , let subTaskReference = record[Detail.subTaskKey] as? CKReference
            else {
                
                print("Error: Could not create the Detail from the CloudKit record.")
                return nil
            }
        
        guard let detailEntity = NSEntityDescription.entity(forEntityName: Detail.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(Detail.type).")
            return nil
        }
        
        self.init(entity: detailEntity, insertInto: context)
        
        self.contentType = contentType
        self.contentValue = contentValue
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        self.sortValue = sortValue
        
        let subTaskIDName = subTaskReference.recordID.recordName
        guard let subTask = SubTaskModelController.shared.fetchSubTaskByIDName(idName: subTaskIDName) else {
            
            print("Error: Could not identify the SubTask by its ID name \"\(subTaskIDName)\".")
            return nil
        }
        
        self.subTask = subTask
    }
}























