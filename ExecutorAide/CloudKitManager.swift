//
//  CloudKitManager.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

private let CreatorUserRecordIDKey = "creatorUserRecordID"
private let LastModifiedUserRecordIDKey = "creatorUserRecordID"
private let CreationDateKey = "creationDate"
private let ModificationDateKey = "modificationDate"

class CloudKitManager {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    init() {
        
        checkCloudKitAvailability()
    }
    
    //==================================================
    // MARK: - User Info Discovery
    //==================================================
    
    func fetchLoggedInUserRecord(database: CKDatabase = CKContainer.default().publicCloudDatabase, completion: ((_ record: CKRecord?, _ error: NSError? ) -> Void)?) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if let error = error,
                let completion = completion {
                completion(nil, error as NSError?)
            }
            
            if let recordID = recordID,
                let completion = completion {
                
                self.fetchRecordWithID(database: self.privateDatabase, recordID: recordID, completion: { (record, error) in
                    completion(record, error as NSError?)
                })
            }
        }
    }
    
    func fetchUsernameFromRecordID(recordID: CKRecordID, completion: ((_ givenName: String?, _ familyName: String?) -> Void)?) {
        
        let userRecordID = CKUserIdentityLookupInfo(userRecordID: recordID)
        let operation = CKDiscoverUserIdentitiesOperation(userIdentityLookupInfos: [userRecordID])
        
        operation.userIdentityDiscoveredBlock = { (userIdentity, userIdentityLookupInfo) in
            
            if let nameComponents = userIdentity.nameComponents {
                
                if let completion = completion {
                    
                    completion(nameComponents.givenName, nameComponents.familyName)
                }
                
            } else if let completion = completion {
                
                completion(nil, nil)
            }
        }
        
        CKContainer.default().add(operation)
    }
    
    func fetchAllDiscoverableUsers(completion: ((_ userInfoRecords: [CKDiscoveredUserInfo]?) -> Void)?) {
        
        let operation = CKDiscoverAllContactsOperation()
        
        operation.discoverAllContactsCompletionBlock = { (discoveredUserInfos, error) -> Void in
            
            if let completion = completion {
                completion(discoveredUserInfos)
            }
        }
        
        CKContainer.default().add(operation)
    }
    
    //==================================================
    // MARK: - Fetch Records
    //==================================================
    
    func fetchRecordWithID(database: CKDatabase = CKContainer.default().publicCloudDatabase, recordID: CKRecordID, completion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?) {
        
        database.fetch(withRecordID: recordID) { (record, error) in
            
            if let completion = completion {
                completion(record, error as NSError?)
            }
        }
    }
    
    func fetchRecordsWithType(database: CKDatabase = CKContainer.default().publicCloudDatabase, type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((_ record: CKRecord) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let predicate = predicate
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            
            fetchedRecords.append(fetchedRecord)
            
            if let recordFetchedBlock = recordFetchedBlock {
                recordFetchedBlock(fetchedRecord)
            }
        }
        
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            
            if let queryCursor = queryCursor {
                // there are more results, go fetch them
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                
                database.add(continuedQueryOperation)
                
            } else {
                if let completion = completion {
                    completion(fetchedRecords, error as NSError?)
                }
            }
        }
        
        database.add(queryOperation)
    }
    
    func fetchCurrentUserRecords(database: CKDatabase = CKContainer.default().publicCloudDatabase, type: String, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        fetchLoggedInUserRecord { (record, error) in
            
            if let record = record {
                
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [CreatorUserRecordIDKey, record.recordID])
                
                self.fetchRecordsWithType(database: database, type: type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    
                    if let completion = completion {
                        completion(records, error as NSError?)
                    }
                })
            }
        }
    }
    
    func fetchRecordsFromDateRange(database: CKDatabase = CKContainer.default().publicCloudDatabase, type: String, recordType: String, fromDate: NSDate, toDate: NSDate, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [CreationDateKey, fromDate])
        let endDatePredicate = NSPredicate(format: "%K < %@", argumentArray: [CreationDateKey, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        
        self.fetchRecordsWithType(database: database, type: type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            
            if let completion = completion {
                completion(records, error as NSError?)
            }
        }
    }
    
    //==================================================
    // MARK: - Delete
    //==================================================
    
    func deleteRecordWithID(database: CKDatabase = CKContainer.default().publicCloudDatabase, recordID: CKRecordID, completion: ((_ recordID: CKRecordID?, _ error: NSError?) -> Void)?) {
        
        database.delete(withRecordID: recordID) { (recordID, error) in
            
            if let completion = completion {
                completion(recordID, error as NSError?)
            }
        }
    }
    
    // TODO: This is missing the call to actually do the delete.  Add it.
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((_ records: [CKRecord]?, _ recordIDs: [CKRecordID]?, _ error: NSError?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.savePolicy = .ifServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            
            if let completion = completion {
                completion(records, recordIDs, error as NSError?)
            }
        }
    }
    
    //==================================================
    // MARK: - Save and Modify
    //==================================================
    
    func saveRecords(database: CKDatabase = CKContainer.default().publicCloudDatabase, records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        self.modifyRecords(database: database, records: records, perRecordCompletion: perRecordCompletion) { (records, error) in
            
            if let completion = completion {
                completion(records, error as NSError?)
            }
        }
    }
    
    func saveRecord(database: CKDatabase = CKContainer.default().publicCloudDatabase, record: CKRecord, completion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?) {
        
        database.save(record) { (record, error) in
            
            if let completion = completion {
                completion(record, error as NSError?)
            }
        }
    }
    
    func modifyRecords(database: CKDatabase = CKContainer.default().publicCloudDatabase , records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        operation.perRecordCompletionBlock = { (record, error) -> Void in
            
            if let perRecordCompletion = perRecordCompletion {
                perRecordCompletion(record, error as NSError?)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            
            if let completion = completion {
                completion(records, error as NSError?)
            }
        }
        
        //        publicDatabase.addOperation(operation)
        database.add(operation)
    }
    
    //==================================================
    // MARK: - Subscriptions
    //==================================================
    
    func subscribe(database: CKDatabase = CKContainer.default().publicCloudDatabase, type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
        
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        database.save(subscription) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription, error as NSError?)
            }
        }
    }
    
    func unsubscribe(database: CKDatabase = CKContainer.default().publicCloudDatabase, subscriptionID: String, completion: ((_ subscriptionID: String?, _ error: NSError?) -> Void)?) {
        
        database.delete(withSubscriptionID: subscriptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                completion(subscriptionID, error as NSError?)
            }
        }
    }
    
    func fetchSubscriptions(database: CKDatabase = CKContainer.default().publicCloudDatabase, completion: ((_ subscriptions: [CKSubscription]?, _ error: NSError?) -> Void)?) {
        
        database.fetchAllSubscriptions { (subscriptions, error) in
            
            if let completion = completion {
                completion(subscriptions, error as NSError?)
            }
        }
    }
    
    func fetchSubscription(database: CKDatabase = CKContainer.default().publicCloudDatabase, subscriptionID: String, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
        
        database.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription, error as NSError?)
            }
        }
    }
    
    //==================================================
    // MARK: - CloudKit Permissions
    //==================================================
    
    func checkCloudKitAvailability() {
        
        CKContainer.default().accountStatus { (accountStatus, error) in
            
            switch accountStatus {
            case .available:
                print("CloudKit available. Initializing full sync.")
                return
            default:
                self.handleCloudKitUnavailable(accountStatus: accountStatus, error: error as NSError?)
            }
        }
    
    
    }
    
    func handleCloudKitUnavailable(accountStatus: CKAccountStatus, error:NSError?) {
        
        var errorText = "Synchronization is disabled\n"
        if let error = error {
            print("handleCloudKitUnavailable ERROR: \(error)")
            print("An error occured: \(error.localizedDescription)")
            errorText += error.localizedDescription
        }
        
        switch accountStatus {
        case .restricted:
            errorText += "iCloud is not available due to restrictions"
        case .noAccount:
            errorText += "There is no CloudKit account setup.\nYou can setup iCloud in the Settings app."
        default:
            break
        }
        
        displayCloudKitNotAvailableError(errorText: errorText)
    }
    
    func displayCloudKitNotAvailableError(errorText: String) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "iCloud Synchronization Error", message: errorText, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //==================================================
    // MARK: - CloudKit Discoverability
    //==================================================
    
    func requestDiscoverabilityPermission() {
        
        CKContainer.default().status(forApplicationPermission: .userDiscoverability) { (permissionStatus, error) in
            
            if permissionStatus == .initialState {
                CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: { (permissionStatus, error) in
                    
                    self.handleCloudKitPermissionStatus(permissionStatus: permissionStatus, error: error as NSError?)
                })
            } else {
                
                self.handleCloudKitPermissionStatus(permissionStatus: permissionStatus, error: error as NSError?)
            }
        }
    }
    
    func handleCloudKitPermissionStatus(permissionStatus: CKApplicationPermissionStatus, error:NSError?) {
        
        if permissionStatus == .granted {
            print("User Discoverability permission granted. User may proceed with full access.")
        } else {
            var errorText = "Synchronization is disabled\n"
            if let error = error {
                print("handleCloudKitUnavailable ERROR: \(error)")
                print("An error occured: \(error.localizedDescription)")
                errorText += error.localizedDescription
            }
            
            switch permissionStatus {
            case .denied:
                errorText += "You have denied User Discoverability permissions. You may be unable to use certain features that require User Discoverability."
            case .couldNotComplete:
                errorText += "Unable to verify User Discoverability permissions. You may have a connectivity issue. Please try again."
            default:
                break
            }
            
            displayCloudKitPermissionsNotGrantedError(errorText: errorText)
        }
    }
    
    func displayCloudKitPermissionsNotGrantedError(errorText: String) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "CloudKit Permissions Error", message: errorText, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
