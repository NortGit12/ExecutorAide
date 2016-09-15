//
//  Stack.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

class Stack {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    static let sharedStack = Stack()
    lazy var managedObjectContext: NSManagedObjectContext = Stack.setUpMainContext()
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    static func setUpMainContext() -> NSManagedObjectContext {
        
//        let bundle = NSBundle.mainBundle()        // original statement
        let bundle = Bundle.main
        
//        guard let model = NSManagedObjectModel.mergedModelFromBundles([bundle])       // original statement
        guard let model = NSManagedObjectModel.mergedModel(from: [bundle])
            else { fatalError("model not found") }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
//        try! persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL(), options: nil)      // original statement
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL() as URL?, options: nil)
        
        let context = NSManagedObjectContext(
//            concurrencyType: .MainQueueConcurrencyType)       // original statement
            concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    static func storeURL () -> NSURL? {
        
//        let documentsDirectory: NSURL? = try? NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)      // original statement
        let documentsDirectory: NSURL? = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true) as NSURL?
        
//        return documentsDirectory?.URLByAppendingPathComponent("db.sqlite")       // original statement
        return documentsDirectory?.appendingPathComponent("db.sqlite") as NSURL?
    }
    
}
