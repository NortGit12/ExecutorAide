//
//  Testator+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public class Testator: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "Testator"
    static let imageKey = "image"
    static let nameKey = "name"
    static let sortValueKey = "sortValue"
    static let stagesKey = "stages"
    
    var recordType: String { return Testator.type }
    
    lazy var temporaryImageURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path URL to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(self.recordName)!.appendingPathExtension("jpg")
        
        if let image = self.image {
            
            image.write(to: fileURL, atomically: true)
        }
        
        return fileURL as NSURL
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Testator.imageKey] = CKAsset(fileURL: self.temporaryImageURL as URL)
        record[Testator.nameKey] = self.name as CKRecordValue?
        record[Testator.sortValueKey] = self.sortValue as CKRecordValue?
        
        var stagesReferencesArray = [CKReference]()
        if self.stages.count > 0 {
            
            for stage in self.stages {
                
                guard let stage = stage as? Stage
                    , let recordIDData = stage.recordIDData as? Data
                    , let recordID = NSKeyedUnarchiver.unarchiveObject(with: recordIDData) as? CKRecordID
                    else { continue }
                
                let stageReference = CKReference(recordID: recordID, action: .deleteSelf)
                stagesReferencesArray.append(stageReference)
            }
            
            record[Testator.stagesKey] = stagesReferencesArray as CKRecordValue?
        }
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(image: NSData, name: String, stages: [Stage]?, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let testatorEntity = NSEntityDescription.entity(forEntityName: Testator.type, in: context) else {
            
            NSLog("Error: Could not create the entity description for a \(Testator.type).")
            return nil
        }
        
        self.init(entity: testatorEntity, insertInto: context)
        
        self.image = image
        self.name = name
        self.recordName = nameForManagedObject()
        
        let stagesMutableOrderedSet = NSMutableOrderedSet()
        if let stages = stages {
            
            for stage in stages {
                
                stagesMutableOrderedSet.add(stage)
            }
            
            self.stages = NSOrderedSet(set: stagesMutableOrderedSet.copy() as! Set<AnyHashable>)
        }

    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let name = record[Testator.nameKey] as? String
            , let imageAssetData = record[Testator.imageKey] as? CKAsset
            , let imageData = NSData(contentsOf: imageAssetData.fileURL)
            else {
                
                NSLog("Error: Could not create the \(Testator.type) from the CloudKit record.")
                return nil
        }
        
        guard let testatorEntity = NSEntityDescription.entity(forEntityName: Testator.type, in: context) else {
            
            NSLog("Error: \(Testator.type) entity could not be created when creating an instance from a CloudKit record.")
            return nil
        }
        
        self.init(entity: testatorEntity, insertInto: context)
        
        self.image = imageData
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
        
        if let stagesReferences = record[Testator.stagesKey] as? [CKReference] {
            
            let stages = setStages(stagesReferences: stagesReferences)
            
            self.stages = NSOrderedSet(array: stages)
        }
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setStages(stagesReferences: [CKReference]) -> [Stage] {
        
        var stages = [Stage]()
        for stagesReference in stagesReferences {
            
            let stageIDName = stagesReference.recordID.recordName
            if let stage = StageModelController.shared.fetchStageByIDName(idName: stageIDName) {
                
                stages.append(stage)
            }
        }
        
        return stages
    }
}




















