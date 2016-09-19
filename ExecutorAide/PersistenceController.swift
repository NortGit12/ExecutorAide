//
//  PersistenceController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class PersistenceController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = PersistenceController()
    let moc = Stack.shared.managedObjectContext
    var cloudKitManager = CloudKitManager()
    var isSyncing: Bool = false
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func saveContext() {
        
        do {
            try moc.save()
        } catch {
            print("Error: Failed to save the Managed Object Context")
        }
    }
    
    //==================================================
    // MARK: - CloudKit Persistence Methods
    //==================================================
    
    func syncedManagedObjects(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: type)
        let predicate = NSPredicate(format: " recordIDData != nil")
        request.predicate = predicate
        
        let syncedRecords = (try? PersistenceController.shared.moc.fetch(request)) as? [CloudKitManagedObject] ?? []
        
        return syncedRecords
    }
    
    func unsyncedManagedObjects(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: type)
        let predicate = NSPredicate(format: " recordIDData == nil")
        request.predicate = predicate
        
        let unsyncedRecords = (try? PersistenceController.shared.moc.fetch(request)) as? [CloudKitManagedObject] ?? []
        
        return unsyncedRecords
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)? = nil) {
        
        var predicate: NSPredicate!
        let moc = PersistenceController.shared.moc
        
        predicate = NSPredicate(value: true)
        
        cloudKitManager.fetchRecordsWithType(database: cloudKitManager.privateDatabase, type: type, predicate: predicate, recordFetchedBlock: { (record) in
            
            /*
             Again, doing this CoreData work on the same thread as the moc
             */
            
            moc.perform({
                
                self.evaluateToCreateNewCoreDataObjectsForCloudKitRecordsByType(type: type, record: record)
                
                PersistenceController.shared.saveContext()
            })
            
        }) { (records, error) in        // completion block
            
            if error != nil {
                print("Error: Could not fetch unsynced CloudKit records: \(error)")
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func evaluateToCreateNewCoreDataObjectsForCloudKitRecordsByType(type: String, record: CKRecord) {
        
        switch type {
            
        case Testator.type:
            
            // Existing CoreData Testator
            guard let _ = TestatorModelController.shared.fetchTestatorByIDName(idName: record.recordID.recordName) else {
                
                // New CoreData Testator
                guard let _ = Testator(record: record) else {
                    
                    NSLog("Error: Could not create a new Testator from the CloudKit record.")
                    return
                }
                
                return
            }
            
        case Stage.type:
            
            // Existing CoreData Stage
            guard let _ = StageModelController.shared.fetchStageByIDName(idName: record.recordID.recordName) else {
                
                // New CoreData Stage
                guard let _ = Stage(record: record) else {
                    
                    NSLog("Error: Could not create a new Stage from the CloudKit record.")
                    return
                }
                
                return
            }
            
        case Task.type:
            
            // Existing CoreData Task
            guard let _ = TaskModelController.shared.fetchTaskByIDName(idName: record.recordID.recordName) else {
                
                // New CoreData Task
                guard let _ = Task(record: record) else {
                    
                    NSLog("Error: Could not create a new Task from the CloudKit record.")
                    return
                }
                
                return
            }
            
        case SubTask.type:
            
            // Existing CoreData SubTask
            guard let _ = SubTaskModelController.shared.fetchSubTaskByIDName(idName: record.recordID.recordName) else {
                
                // New CoreData SubTask
                guard let _ = SubTask(record: record) else {
                    
                    NSLog("Error: Could not create a new SubTask from the CloudKit record.")
                    return
                }
                
                return
            }
            
        case Detail.type:
            
            // Existing CoreData Detail
            guard let _ = DetailModelController.shared.fetchDetailByIDName(idName: record.recordID.recordName) else {
                
                // New CoreData Detail
                guard let _ = Detail(record: record) else {
                    
                    NSLog("Error: Could not create a new Detail from the CloudKit record.")
                    return
                }
                
                return
            }
            
        default: return
        }
    }
    
    func pushChangesToCloudKit(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        let unsyncedManagedObjectsArray = self.unsyncedManagedObjects(type: Testator.type) + self.unsyncedManagedObjects(type: Stage.type)
            + self.unsyncedManagedObjects(type: Task.type) + self.unsyncedManagedObjects(type: SubTask.type) + self.unsyncedManagedObjects(type: Detail.type)
        let unsyncedRecordsArray = unsyncedManagedObjectsArray.flatMap({ $0.cloudKitRecord })
        
        cloudKitManager.saveRecords(database: cloudKitManager.privateDatabase, records: unsyncedRecordsArray, perRecordCompletion: { (record, error) in     // per record block
            
            if error != nil {
                print("Error: Could not push unsynced record to CloudKit: \(error)")
            }
            
            guard let record = record else {
                
                NSLog("Error: Could not unwrap the saved record.")
                return
            }
            
            /*
             This supports multi-threading.  Anything we do with MangedObjectContexts must need to be done on the same thread that it is in.  The code inside this cloudKitManager.saveRecords(...) method will be on a background thread and the MangedObjectContext (moc) is on the main thread, so we need a way to get this.  ALL pieces of things that deal with Core Data need to be in here, working on the main thread where the moc is.  In here the $0.recordName accesses Core Data and so does the .update(...) method.
             */
            
            let moc = PersistenceController.shared.moc
            moc.perform({
                
                if let matchingRecord = unsyncedManagedObjectsArray.filter({ $0.recordName == record.recordID.recordName }).first {
                    
                    matchingRecord.updateRecordIDData(record: record)
                }
            })
            
        }) { (records, error) in        // completion block
            
            if error != nil {
                print("Error saving unsynced record to CloudKit: \(error)")
            }
            
            if let completion = completion {
                
                let success = records != nil
                completion(success, error)
            }
        }
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
        if isSyncing == true {
            
            if let completion = completion {
                
                // Doing this here is okay, but not ideal
                completion()
            }
        } else {
            
            isSyncing = true
            
            pushChangesToCloudKit(completion: { (_) in
                
                print("Pushing changes to CloudKit...")
                
                self.fetchNewRecords(type: Testator.type) {
                    
                    print("Fetching new Testator(s) from CloudKit...")
                    
                    self.fetchNewRecords(type: Stage.type) {
                        
                        print("Fetching new Stage(s) from CloudKit...")
                        
                        self.fetchNewRecords(type: Task.type) {
                            
                            print("Fetching new Task(s) from CloudKit...")
                            
                            self.fetchNewRecords(type: SubTask.type) {
                                
                                print("Fetching new SubTask(s) from CloudKit...")
                                
                                self.fetchNewRecords(type: Detail.type) {
                                    
                                    print("Fetching new Detail(s) from CloudKit...")
                                    
                                    self.isSyncing = false
                                    
                                    if let completion = completion {
                                        completion()
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func identifyManagedObjectType(recordID: CKRecordID) -> String {
        
        let testatorManagedObject = TestatorModelController.shared.fetchTestatorByIDName(idName: recordID.recordName)
        let stageManagedObject = StageModelController.shared.fetchStageByIDName(idName: recordID.recordName)
        let taskManagedObject = TaskModelController.shared.fetchTaskByIDName(idName: recordID.recordName)
        let subTaskManagedObject = SubTaskModelController.shared.fetchSubTaskByIDName(idName: recordID.recordName)
        let detailManagedObject = DetailModelController.shared.fetchDetailByIDName(idName: recordID.recordName)
        
        var managedObjectType = String()
        
        if testatorManagedObject != nil { managedObjectType = Testator.type}
        else if stageManagedObject != nil { managedObjectType = Stage.type}
        else if taskManagedObject != nil { managedObjectType = Task.type}
        else if subTaskManagedObject != nil { managedObjectType = SubTask.type}
        else if detailManagedObject != nil { managedObjectType = Detail.type}
        
        return managedObjectType
    }
}

















