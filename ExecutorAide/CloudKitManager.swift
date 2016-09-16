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
    
    // MARK: - User Info Discovery
    
    func fetchLoggedInUserRecord(completion: ((_ record: CKRecord?, _ error: NSError? ) -> Void)?) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if let error = error,
                let completion = completion {
                completion(nil, error as NSError?)
            }
            
            if let recordID = recordID,
                let completion = completion {
                
                self.fetchRecordWithID(recordID: recordID, completion: { (record, error) in
                    completion(record, error)
                })
            }
        }
    }
    
    func fetchUsernameFromRecordID(recordID: CKRecordID, completion: ((_ givenName: String?, _ familyName: String?) -> Void)?) {
        
        let userRecordInfo = CKUserIdentityLookupInfo(userRecordID: recordID)
        
        let operation = CKDiscoverUserInfosOperation(emailAddresses: nil, userRecordIDs: [recordID])
//        let operation = CKDiscoverUserIdentitiesOperation(userIdentityLookupInfos: [userRecordInfo])
        
        operation.discoverUserInfosCompletionBlock = { (emailsToUserInfos, userRecordIDsToUserInfos, operationError) -> Void in
            
            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
                let userInfo = userRecordIDsToUserInfos[recordID],
                let completion = completion {
                
                completion(userInfo.displayContact?.givenName, userInfo.displayContact?.familyName)
            } else if let completion = completion {
                completion(nil, nil)
            }
        }
        
//        operation.discoverUserIdentitiesCompletionBlock = { (error: Error?) in
//            
//            let userRecordInfo = userRecordInfo
//            userRecordInfo.
//            
//            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
//                let userInfo = userRecordIDsToUserInfos[recordID],
//                let completion = completion {
//                
//                completion(userInfo.displayContact?.givenName, userInfo.displayContact?.familyName)
//            } else if let completion = completion {
//                completion(nil, nil)
//            }
//        }
        
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
    
    
    // MARK: - Fetch Records
    
    func fetchRecordWithID(recordID: CKRecordID, completion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            
            if let completion = completion {
                completion(record, error as NSError?)
            }
        }
    }
    
    func fetchRecordsWithType(type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((_ record: CKRecord) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
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
                
                self.publicDatabase.add(continuedQueryOperation)
            } else {
                if let completion = completion {
                    completion(fetchedRecords, error as NSError?)
                }
            }
        }
        
        self.publicDatabase.add(queryOperation)
    }
    
    func fetchCurrentUserRecords(type: String, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        fetchLoggedInUserRecord { (record, error) in
            
            if let record = record {
                
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [CreatorUserRecordIDKey, record.recordID])
                
                self.fetchRecordsWithType(type: type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    
                    if let completion = completion {
                        completion(records, error)
                    }
                })
            }
        }
    }
    
    func fetchRecordsFromDateRange(_ type: String, _ recordType: String, _ fromDate: NSDate, _ toDate: NSDate, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [CreationDateKey, fromDate])
        let endDatePredicate = NSPredicate(format: "%K < %@", argumentArray: [CreationDateKey, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        
        self.fetchRecordsWithType(type: type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            
            if let completion = completion {
                completion(records, error)
            }
        }
    }
    
    
    // MARK: - Delete
    
    func deleteRecordWithID(recordID: CKRecordID, completion: ((_ recordID: CKRecordID?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            
            if let completion = completion {
                completion(recordID, error as NSError?)
            }
        }
    }
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((_ records: [CKRecord]?, _ recordIDs: [CKRecordID]?, _ error: NSError?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.savePolicy = .ifServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            
            if let completion = completion {
                completion(records, recordIDs, error as NSError?)
            }
        }
    }
    
    
    // MARK: - Save and Modify
    
    func saveRecords(records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
        modifyRecords(records: records, perRecordCompletion: perRecordCompletion) { (records, error) in
            
            if let completion = completion {
                completion(records, error as NSError?)
            }
        }
    }
    
    func saveRecord(record: CKRecord, completion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.save(record) { (record, error) in
            
            if let completion = completion {
                completion(record, error as NSError?)
            }
        }
    }
    
    func modifyRecords(records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: NSError?) -> Void)?) {
        
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
        
        publicDatabase.add(operation)
    }
    
    
    // MARK: - Subscriptions
    
//    func subscribe(type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
    func subscribe(type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKQuerySubscriptionOptions, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
    
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.save(subscription) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription, error as NSError?)
            }
        }
    }
    
    func unsubscribe(subscriptionID: String, completion: ((_ subscriptionID: String?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.delete(withSubscriptionID: subscriptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                completion(subscriptionID, error as NSError?)
            }
        }
    }
    
    func fetchSubscriptions(completion: ((_ subscriptions: [CKSubscription]?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.fetchAllSubscriptions { (subscriptions, error) in
            
            if let completion = completion {
                completion(subscriptions, error as NSError?)
            }
        }
    }
    
    func fetchSubscription(subscriptionID: String, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
        
        publicDatabase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription, error as NSError?)
            }
        }
    }
    
    
    // MARK: - CloudKit Permissions
    
    func checkCloudKitAvailability() {
        
        CKContainer.default().accountStatusWithCompletionHandler() {
            (accountStatus:CKAccountStatus, error:NSError?) -> Void in
            
            switch accountStatus {
            case .Available:
                print("CloudKit available. Initializing full sync.")
                return
            default:
                self.handleCloudKitUnavailable(accountStatus, error: error)
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
        
        dispatch_get_main_queue().asynchronously(execute: {
            
            let alertController = UIAlertController(title: "iCloud Synchronization Error", message: errorText, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    
    // MARK: - CloudKit Discoverability
    
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
        
        dispatch_async(dispatch_get_main_queue(),{
            
            let alertController = UIAlertController(title: "CloudKit Permissions Error", message: errorText, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        })
    }
}
