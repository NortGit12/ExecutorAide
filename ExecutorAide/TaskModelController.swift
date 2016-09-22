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
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createTask(name: String, sortValue: Int, completion: (() -> Void)? = nil) {
        
        let task = Task(name: name, sortValue: sortValue)
        
        PersistenceController.shared.moc.performAndWait {
            PersistenceController.shared.saveContext()
        }
        
        if let taskCloudKitRecord = task?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: taskCloudKitRecord, completion: { (record, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    print("Error: New task \"\(task?.name)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let record = record {
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines would run immeciately.
                     */
                    PersistenceController.shared.moc.performAndWait {
                        task?.updateRecordIDData(record: record)
                        print("New task \"\(task?.name)\" successfully saved to CloudKit.")
                    }
                }
            })
        }
    }
    
    func create(tasks: [Task], completion: (() -> Void)? = nil) {
        
        PersistenceController.shared.moc.performAndWait {
            PersistenceController.shared.saveContext()
        }
        
        var counter = 0
        for task in tasks {
            
            if let taskCloudKitRecord = task.cloudKitRecord {
                
                cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: taskCloudKitRecord, completion: { (record, error) in
                    
                    if error != nil {
                        
                        print("Error: New task \"\(task.name)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                        return
                    }
                    
                    if let record = record {
                        
                        /*
                         The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines would run immeciately.
                         */
                        
                        PersistenceController.shared.moc.performAndWait {
                            
                            task.updateRecordIDData(record: record)
                            print("New task \"\(task.name)\" successfully saved to CloudKit.")
                            counter += 1
                            
                            // If all stages have been saved, execute completion
                            if counter == tasks.count {
                                
                                if let completion = completion {
                                    completion()
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func fetchTasks() -> [Task]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Task]
            guard let sortedResultsArray = resultsArray?.sorted(by: { $0.sortValue < $1.sortValue }) else {
                
                print("Error: The tasks array could not be sorted.")
                return nil
            }
            
            return sortedResultsArray
            
        } catch let error {
            
            print("Error fetching all Tasks: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchTaskByIDName(idName: String) -> Task? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Task]
            
            return resultsArray?.first
            
        } catch let error {
            
            print("Error fetching Task with ID \"\(idName)\": \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateTask(task: Task, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [task.recordName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Task]
            let existingTask = resultsArray?.first
            
            existingTask?.name = task.name
            existingTask?.recordIDData = nil
            existingTask?.sortValue = task.sortValue
            existingTask?.stage = task.stage
            existingTask?.subTasks = task.subTasks
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.saveContext()
            }
            
        } catch let error {
            
            print("Error updating Task \"\(task.name)\": \(error.localizedDescription)")
            return
        }
        
        if let taskCloudKitRecord = task.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [taskCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    print("Error: Could not modify the existing \"\(task.name)\" task in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    print("Updated \"\(task.name)\" task saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteTask(task: Task, completion: (() -> Void)? = nil) {
        
        if let taskCloudKitRecord = task.cloudKitRecord {
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.moc.delete(task)
                PersistenceController.shared.saveContext()
            }
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: taskCloudKitRecord.recordID, completion: { (recordID, error) in
                
                if let taskName = taskCloudKitRecord[Task.nameKey] {
                    
                    defer {
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                    
                    if error != nil {
                        
                        print("Error: Task \"\(taskName)\" could not be deleted in CloudKit.  \(error?.localizedDescription)")
                        return
                    }
                    
                    if let _ = recordID {
                        
                        print("Task \"\(taskName)\" successfully deleted from CloudKit.")
                    }
                }
            })
        }
    }
}





























