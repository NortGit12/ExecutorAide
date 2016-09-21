//
//  TestatorModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import CoreData

class TestatorModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = TestatorModelController()
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createTestator(image: UIImage?, name: String, completion: ((_ testator: Testator?) -> Void)? = nil) {
        
        guard let image = image
            , let imageData = UIImagePNGRepresentation(image)
            else {
                
                print("Error: Could not access the Testator's image data.")
                return
            }
        
        let testator = Testator(image: imageData as NSData, name: name)
        PersistenceController.shared.saveContext()
        
        if let testatorCloudKitRecord = testator?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: testatorCloudKitRecord, completion: { (record, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion(testator)
                    }
                }
                
                if error != nil {
                    
                    print("Error: New Testator could not be saved to CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let record = record {
                    
                    let moc = PersistenceController.shared.moc
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would e done asynchronously on another thread and the subsequent lines would run immediately.
                     */
                    
                    moc.perform({ 
                        
                        testator?.updateRecordIDData(record: record)
                        print("New Testator \"\(testator?.name)\" successfully saved to CloudKit.")
                    })
                }
            })
        }
    }
    
    func fetchTestators() -> [Testator] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Testator.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        var resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Testator]
        resultsArray?.sort(by: { $0.0.name < $0.1.name })
        
        return (resultsArray ?? nil)!
    }
    
    func fetchTestatorByIDName(idName: String) -> Testator? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Testator.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Testator]
        
        return resultsArray?.first ?? nil
    }
    
    func updateTestator(testator: Testator, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Testator.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [testator.recordName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Testator]
        let existingTestator = resultsArray?.first
        
        existingTestator?.name = testator.name
        existingTestator?.recordIDData = nil
        existingTestator?.image = testator.image
        existingTestator?.stages = testator.stages
        
        PersistenceController.shared.saveContext()
        
        if let testatorCloudKitRecord = testator.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [testatorCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                    
                if error != nil {
                    
                    print("Error: Could not modify the existing \"\(testator.name)\" testator in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    print("Updated \"\(testator.name)\" testator saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteTestator(testator: Testator, completion: (() -> Void)? = nil) {
        
        if let testatorCloudKitRecord = testator.cloudKitRecord {
            
            PersistenceController.shared.moc.delete(testator)
            PersistenceController.shared.saveContext()
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: testatorCloudKitRecord.recordID, completion: { (recordID, error) in
                
                if let testatorName = testatorCloudKitRecord[Testator.nameKey] {
                    
                    defer {
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                    
                    if error != nil {
                        
                        print("Error: Testator \"\(testatorName)\" could not be deleted in CloudKit.  \(error?.localizedDescription)")
                        return
                    }
                    
                    if let _ = recordID {
                        
                        print("Testator \"\(testatorName)\" successfully deleted from CloudKit.")
                    }
                }
            })
        }
    }
}





















