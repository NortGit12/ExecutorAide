//
//  TaskModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

class TaskModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = TaskModelController()
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
    
    func createTask(name: String, sortValue: Int, stage: Stage, subTasks: [SubTask]?, completion: (() -> Void)? = nil) {
        
        let task = Task(name: name, sortValue: sortValue, stage: stage, subTasks: subTasks)
        
        PersistenceController.shared.saveContext()
        
        if let taskCloudKitRecord = task?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: taskCloudKitRecord, completion: { (record, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: New task \"\(task?.name)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let record = record {
                    
                    let moc = PersistenceController.shared.moc
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines would run immeciately.
                     */
                    
                    moc.performAndWait {
                        
                        task?.updateRecordIDData(record: record)
                        NSLog("New task \"\(task?.name)\" successfully saved to CloudKit.")
                    }
                }
            })
        }
    }
    
    func fetchTasks() -> [Task]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Task]
        guard let sortedResultsArray = resultsArray?.sorted(by: { $0.sortValue < $1.sortValue }) else {
            
            NSLog("Error: The tasks array could not be sorted.")
            return nil
        }
        
        return sortedResultsArray
    }
    
    func fetchTaskByIDName(idName: String) -> Task? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Task]
        
        return resultsArray?.first ?? nil
    }
    
    func updateTask(task: Task, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [task.recordName])
        request.predicate = predicate
        
        let resultsArray = (try? PersistenceController.shared.moc.fetch(request)) as? [Task]
        let existingTask = resultsArray?.first
        
        existingTask?.name = task.name
        existingTask?.sortValue = task.sortValue
        existingTask?.stage = task.stage
        existingTask?.subTasks = task.subTasks
        
        PersistenceController.shared.saveContext()
        
        if let taskCloudKitRecord = task.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [taskCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: Could not modify the existing \"\(task.name)\" task in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    NSLog("Updated \"\(task.name)\" task saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteTask(task: Task, completion: (() -> Void)? = nil) {
        
        if let taskCloudKitRecord = task.cloudKitRecord {
            
            PersistenceController.shared.moc.delete(task)
            PersistenceController.shared.saveContext()
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: taskCloudKitRecord.recordID, completion: { (recordID, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    NSLog("Error: Task \"\(task.name)\" could not be deleted in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = recordID {
                    
                    NSLog("Task \"\(task.name)\" successfully deleted from CloudKit.")
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





























