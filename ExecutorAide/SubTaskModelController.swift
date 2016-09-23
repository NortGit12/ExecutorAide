//
//  SubTaskModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

class SubTaskModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = SubTaskModelController()
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createSubTask(descriptor: String?, isCompleted: Bool = false, name: String, sortValue: Int, task: Task, completion: (() -> Void)?) {
        
        let subTask = SubTask(descriptor: descriptor, isCompleted: isCompleted, name: name, sortValue: sortValue, task: task)
        
        PersistenceController.shared.moc.performAndWait {
            PersistenceController.shared.saveContext()
        }
        
        if let subTaskCloudKitRecord = subTask?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: subTaskCloudKitRecord, completion: { (record, error) in
                
                if error != nil {
                    
                    print("Error: New sub-task \"\(subTask?.name)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                    
                    if let completion = completion {
                        completion()
                        return
                    }
                }
                
                if let record = record {
                    
                    /*
                     The "...AndWait" makes the subsequent work wiat for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines would run immediately.
                     */
                    
                    PersistenceController.shared.moc.performAndWait({
                        
                        subTask?.updateRecordIDData(record: record)
                        print("New sub-task \"\(subTask?.name)\" successfully saved to CloudKit.")
                        
                        if let completion = completion {
                            completion()
                        }
                    })
                }
            })
        }
    }
    
    func create(subTasks: [SubTask], completion: (() -> Void)?) {
        PersistenceController.shared.moc.performAndWait {
            var counter = 0
            for subTask in subTasks {
                self.createSubTask(descriptor: subTask.descriptor, name: subTask.name, sortValue: subTask.sortValue, task: subTask.task, completion: {
                    counter += 1
                    
                    if counter == subTasks.count {
                        if let completion = completion {
                            completion()
                        }
                    }
                })
            }
        }
    }
    
    func fetchSubTasks() -> [SubTask]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SubTask.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [SubTask]
            guard let sortedResultsArray = resultsArray?.sorted(by: { $0.sortValue < $1.sortValue }) else {
                
                print("Error: The sub-tasks array could not be sorted.")
                return nil
            }
            
            return sortedResultsArray
            
        } catch let error {
            
            print("Error fetching all SubTasks: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchSubTaskByIDName(idName: String) -> SubTask? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SubTask.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [SubTask]
            
            return resultsArray?.first
            
        } catch let error {
            
            print("Error fetching SubTask with ID \"\(idName)\": \(error.localizedDescription)")
            return nil
        }

    }
    
    func updateSubTask(subTask: SubTask, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SubTask.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [subTask.recordName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [SubTask]
            let existingSubTask = resultsArray?.first
            
            existingSubTask?.descriptor = subTask.descriptor
            existingSubTask?.isCompleted = subTask.isCompleted
            existingSubTask?.name = subTask.name
            existingSubTask?.recordIDData = nil
            existingSubTask?.sortValue = subTask.sortValue
            existingSubTask?.task = subTask.task
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.saveContext()
            }
            
        } catch let error {
            
            print("Error updating SubTask \"\(subTask.name)\": \(error.localizedDescription)")
            return
        }
        
        if let subTaskCloudKitRecord = subTask.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [subTaskCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    print("Error: Could not modify the existing \"\(subTask.name)\" sub-task in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    print("Updated \"\(subTask.name)\" sub-task saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteSubTask(subTask: SubTask, completion: (() -> Void)? = nil) {
        
        if let subTaskCloudKitRecord = subTask.cloudKitRecord {
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.moc.delete(subTask)
                PersistenceController.shared.saveContext()
            }
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: subTaskCloudKitRecord.recordID, completion: { (recordID, error) in
                
                if let subTaskName = subTaskCloudKitRecord[SubTask.nameKey] {
                    
                    defer {
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                    
                    if error != nil {
                        
                        print("Error: Sub-task \"\(subTaskName)\" could not be deleted in CloudKit.  \(error?.localizedDescription)")
                        return
                    }
                    
                    if let _ = recordID {
                        
                        print("Sub-task \"\(subTaskName)\" successfully deleted from CloudKit.")
                    }
                }
            })
        }
    }
}
























