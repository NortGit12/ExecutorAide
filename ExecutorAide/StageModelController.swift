//
//  StageModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

class StageModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = StageModelController()
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init() {
        
        // Call createInitialDataSet() to populate an initial set of data for a new Testator
        //        createInitialDataSet()
    }
    
    //==================================================
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createStage(descriptor: String, name: String, percentComplete: Float = 0.0, sortValue: Int, tasks: [Task], completion: (() -> Void)? = nil) {
        
        let stage = Stage(descriptor: descriptor, name: name, percentComplete: percentComplete, sortValue: sortValue, tasks: tasks)
        
        PersistenceController.shared.saveContext()
        
        if let stageCloudKitRecord = stage?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: stageCloudKitRecord, completion: { (record, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: New Stage \"\(stage?.name)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let record = record {
                    
                    let moc = PersistenceController.shared.moc
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for teh perform block to finish.  By default, the moc. performBlock(...) is asynchronous, so the work in there would e done asynchronously on another thread and the subsequent lines would run immediately.
                     */
                    
                    moc.performAndWait {
                        
                        stage?.updateRecordIDData(record: record)
                        NSLog("New Stage \"\(stage?.name)\" successfully saved to CloudKit.")
                    }
                }
            })
        }
    }
    
    func fetchStages() -> [Stage]? {
        
        let request  = NSFetchRequest<NSFetchRequestResult>(entityName: Stage.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Stage]
        guard let sortedResultsArray = resultsArray?.sorted(by: { $0.sortValue < $1.sortValue }) else {
            
            NSLog("Error: The stages array could not be sorted.")
            return nil
        }
        
        return sortedResultsArray
    }
    
    func fetchStageByIDName(idName: String) -> Stage? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Stage.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Stage]
        
        return resultsArray?.first ?? nil
    }
    
    func updateStage(stage: Stage, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Stage.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [stage.recordName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Stage]
        let existingStage = resultsArray?.first
        
        existingStage?.descriptor = stage.descriptor
        existingStage?.name = stage.name
        existingStage?.percentComplete = stage.percentComplete
        existingStage?.sortValue = stage.sortValue
        existingStage?.tasks = stage.tasks
        
        PersistenceController.shared.saveContext()
        
        if let stageCloudKitRecord = stage.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [stageCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: Could not modify the existing \"\(stage.name)\" stage in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    NSLog("Updated \"\(stage.name)\" stage saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteStage(stage: Stage, completion: (() -> Void)? = nil) {
        
        if let stageCloudKitRecord = stage.cloudKitRecord {
            
            PersistenceController.shared.moc.delete(stage)
            PersistenceController.shared.saveContext()
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: stageCloudKitRecord.recordID, completion: { (recordID, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: Stage \"\(stage.name)\" could not be deleted in CloudKit.")
                    return
                }
                
                if let _ = recordID {
                    
                    NSLog("Stage \"\(stage.name)\" successfully deleted from CloudKit.")
                }
            })
        }
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
        
        // TODO: Finish implementation
    }
}






























