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
    static let stagesKey = "stages"

//    public override func awakeFromInsert() {
//        super.awakeFromInsert()
//        // create default template
////        DataTemplateController.initializeTemplate()
//    }
    
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
        record[Testator.nameKey] = self.name as NSString

        return record
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    convenience init?(image: NSData, name: String, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let testatorEntity = NSEntityDescription.entity(forEntityName: Testator.type, in: context) else {
            
            print("Error: Could not create the entity description for a \(Testator.type).")
            return nil
        }
        
        self.init(entity: testatorEntity, insertInto: context)
        
        self.image = image
        self.name = name
        self.recordName = nameForManagedObject()
    }
    
    convenience required public init?(record: CKRecord, context: NSManagedObjectContext = Stack.shared.managedObjectContext) {
        
        guard let name = record[Testator.nameKey] as? String
            , let imageAssetData = record[Testator.imageKey] as? CKAsset
            , let imageData = NSData(contentsOf: imageAssetData.fileURL)
            else {
                
                print("Error: Could not create the \(Testator.type) from the CloudKit record.")
                return nil
        }
        
        guard let testatorEntity = NSEntityDescription.entity(forEntityName: Testator.type, in: context) else {
            
            print("Error: \(Testator.type) entity could not be created when creating an instance from a CloudKit record.")
            return nil
        }
        
        self.init(entity: testatorEntity, insertInto: context)
        
        self.image = imageData
        self.name = name
        self.recordIDData = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData?
        self.recordName = record.recordID.recordName
    }
}




















