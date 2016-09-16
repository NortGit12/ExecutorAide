//
//  TestatorModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class TestatorModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = TestatorModelController()
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
    
    func createTestator(name: String, image: UIImage?, completion: (() -> Void)? = nil) {
        
        guard let image = image
            , let imageData = UIImagePNGRepresentation(image)
            else {
                
                NSLog("Error: Could not access the Testator's image data.")
                return
            }
        
        let testator = Testator(name: name, image: imageData as NSData)
        PersistenceController.shared.saveContext()
        
//        if let testatorCloudKitRecord = testator?.cloudKitRecord {
//            
//            cloudKitManager.save
//        }
        
        // TODO: Finish implementation
    }
    
    func fetchTestators() -> [Testator] {
        
        // TODO: Finish implementation
        
        return [Testator]()
    }
    
    func fetchTestatorByIDName(idName: String) -> Testator? {
        
        // TODO: Finish implementation
        
        return nil
    }
    
    func updateTestator(testator: Testator, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func archiveTestator(testator: Testator, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
    
        // TODO: Finish implementation
    }
}
