//
//  Testator.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class Testator: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "Testator"
    static let nameKey = "name"
    static let imageKey = "image"
    static let stagesKey = "stages"
    
    var recordType: String { return Testator.type }
    
    lazy var temporaryImageURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path URL to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName)!.URLByAppendingPathExtension("jpg")
        
        if let image = self.image {
        
            image.writeToURL(fileURL!, atomically: true)
        }
        
        return fileURL!
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: self.recordName)
        let record = CKRecord(recordType: Testator.type, recordID: recordID)
        
        record[Testator.nameKey] = self.name
        record[Testator.imageKey] = CKAsset(fileURL: self.temporaryImageURL)
        
        var stagesReferencesArray = [CKReference]()
        for stage in stages {
            
            guard let recordIDData = stage.recordIDData
                , let recordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData!) as? CKRecordID
                else { continue }
            
            let stageReference = CKReference(recordID: recordID, action: .DeleteSelf)
            stagesReferencesArray.append(stageReference)
        }
        
        record[Testator.stagesKey] = stagesReferencesArray
        
        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(name: String, image: NSData, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let testatorEntity = NSEntityDescription.entityForName(Testator.type, inManagedObjectContext: context) else {
            
            NSLog("Error: Could not create the entity description for a \(Testator.type).")
            return nil
        }
        
        self.init(entity: testatorEntity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.image = image
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let name = record[Testator.nameKey] as? String
            , let imageAssetData = record[Testator.imageKey] as? CKAsset
            , let imageData = NSData(contentsOfURL: imageAssetData.fileURL)
            else {
                
                NSLog("Error: Could not create the \(Testator.type) from the CloudKit record.")
                return nil
            }
        
        guard let testatorEntity = NSEntityDescription.entityForName(Testator.type, inManagedObjectContext: context) else { return nil }
        
        self.init(entity: testatorEntity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.image = imageData
    }
}
