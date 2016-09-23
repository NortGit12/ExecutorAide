//
//  DetailModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

class DetailModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = DetailModelController()
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createDetail(contentType: String, contentValue: String, sortValue: Int, subTask: SubTask, completion: (() -> Void)? = nil) {
        
        let detail = Detail(contentType: contentType, contentValue: contentValue, sortValue: sortValue, subTask: subTask)
        
        PersistenceController.shared.moc.performAndWait {
            PersistenceController.shared.saveContext()
        }
        
        if let detailCloudKitRecord = detail?.cloudKitRecord {
            
            cloudKitManager.saveRecord(database: cloudKitManager.privateDatabase, record: detailCloudKitRecord, completion: { (record, error) in
                
                if error != nil {
                    print("Error: New detail \"\(detail?.contentType)\" could not be saved to CloudKit.  \(error?.localizedDescription)")
                    if let completion = completion {
                        completion()
                        return
                    }
                }
                
                if let record = record {
                    
                    /*
                     The "...AndWait" makes the subsequent work wait for the performBlock to finish.  By default, the moc.performBlock(...) is asynchronous, so the work in there would be done asynchronously on another thread and the subsequent lines woul run immediately.
                     */
                    
                    PersistenceController.shared.moc.performAndWait({
                        
                        detail?.updateRecordIDData(record: record)
                        print("New detail \"\(detail?.contentType)\" successfully saved to CloudKit.")
                        
                        if let completion = completion {
                            completion()
                        }
                    })
                }
            })
        }
    }
    
    func fetchDetails() -> [Detail]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Detail.type)
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Detail]
            guard let sortedResultsArray = resultsArray?.sorted(by: { $0.sortValue < $1.sortValue }) else {
                
                print("Error: The details array could not be sorted.")
                return nil
            }
            
            return sortedResultsArray
            
        } catch let error {
            
            print("Error fetching all Details: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchDetailByIDName(idName: String) -> Detail? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Detail.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [idName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Detail]
            
            return resultsArray?.first
            
        } catch let error {
            
            print("Error fetching Detail with ID \"\(idName)\": \(error.localizedDescription)")
            return nil
        }

    }
    
    func updateDetail(detail: Detail, completion: (() -> Void)? = nil) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Detail.type)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [detail.recordName])
        request.predicate = predicate
        
        do {
            let resultsArray = try PersistenceController.shared.moc.fetch(request) as? [Detail]
            let existingDetail = resultsArray?.first
            
            existingDetail?.contentType = detail.contentType
            existingDetail?.contentValue = detail.contentValue
            existingDetail?.recordIDData = nil
            existingDetail?.sortValue = detail.sortValue
            existingDetail?.subTask = detail.subTask
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.saveContext()
            }
            
        } catch let error {
            
            print("Error updating Detail \"\(detail.contentType)\": \(error.localizedDescription)")
            return
        }
        
        if let detailCloudKitRecord = detail.cloudKitRecord {
            
            cloudKitManager.modifyRecords(database: cloudKitManager.privateDatabase, records: [detailCloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
                
                defer {
                    
                    if let completion = completion {
                        completion()
                    }
                }
                
                if error != nil {
                    
                    print("Error: Could not modify the existing \"\(detail.contentType)\" detail in CloudKit.  \(error?.localizedDescription)")
                    return
                }
                
                if let _ = records {
                    
                    print("Updated \"\(detail.contentType)\" detail saved successfully to CloudKit.")
                }
            })
        }
    }
    
    func deleteDetail(detail: Detail, completion: (() -> Void)? = nil) {
        
        if let detailCloudKitRecord = detail.cloudKitRecord {
            
            PersistenceController.shared.moc.performAndWait {
                PersistenceController.shared.moc.delete(detail)
                PersistenceController.shared.saveContext()
            }
            
            cloudKitManager.deleteRecordWithID(database: cloudKitManager.privateDatabase, recordID: detailCloudKitRecord.recordID, completion: { (recordID, error) in
                
                if let detailContentType = detailCloudKitRecord[Detail.contentTypeKey] {
                    
                    defer {
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                    
                    if error != nil  {
                        
                        print("Error: Detail \"\(detailContentType)\" could not be deleted in CloudKit.  \(error?.localizedDescription)")
                        return
                    }
                    
                    if let _ = recordID {
                        
                        print("Detail \"\(detailContentType)\" successfully deleted from CloudKit.")
                    }
                }
            })
        }
    }
}























