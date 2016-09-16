//
//  DetailModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation

class DetailModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = TestatorModelController()
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init() {
        
    }
    
    //==================================================
    // MARK: - Methods (CRUD)
    //==================================================
    
    func createDetail(contentType: String, contentValue: String, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func fetchDetails() -> [Detail] {
        
        // TODO: Finish implementation
        
        return [Detail]()
    }
    
    func fetchDetailByIDName(idName: String) -> Detail? {
        
        // TODO: Finish implementation
        
        return nil
    }
    
    func updateDetail(detail: Detail, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func archiveDetail(detail: Detail, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
        
        // TODO: Finish implementation
    }
}
