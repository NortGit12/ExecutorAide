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
        
        var record = CKRecord(recordType: Stage.type)
        PersistenceController.shared.moc.performAndWait {
            
            let recordID = CKRecordID(recordName: self.recordName)
            record = CKRecord(recordType: self.recordType, recordID: recordID)
            
            record[Stage.descriptorKey] = self.descriptor as NSString
            record[Stage.nameKey] = self.name as NSString
            record[Stage.percentCompleteKey] = self.percentComplete as NSNumber
            record[Stage.sortValueKey] = self.sortValue as NSNumber
            
            guard let testatorCloudKitRecord = self.testator.cloudKitRecord
                else {
                    print("Error: Could not unarchive the Testator's recordID when attempting to compute the cloudKitRecord for a Stage.")
                    return
            }
            
            let testatorRecordID = testatorCloudKitRecord["recordID"] as! CKRecordID
            let testatorReference = CKReference(recordID: testatorRecordID, action: .deleteSelf)
            record[Stage.testatorKey] = testatorReference as CKReference
            
        }
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(descriptor: String, name: String, percentComplete: Float = 0.0, sortValue: Int, testator: Testator, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        if descriptor.characters.count == 0 {
            print("Error: The Stage descriptor is empty.")
            return nil
        }
        
        if name.characters.count == 0 {
            print("Error: The Stage name is empty.")
            return nil
        }
        
        if percentComplete < 0.0 || percentComplete > 1.0 {
            print("Error: The Stage percent complete is outside of the acceptable range (0.0 to 1.0).")
            return nil
        }
        
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
        
        let testatorIDName = testatorReference.recordID.recordName
        guard let testator = TestatorModelController.shared.fetchTestatorByIDName(idName: testatorIDName) else {
            
            print("Error: Could not identify the testator by its ID name \"\(testatorIDName)\".")
            return nil
        }
        
        self.testator = testator
    }
}
























