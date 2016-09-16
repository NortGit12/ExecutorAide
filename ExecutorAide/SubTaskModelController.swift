//
//  SubTaskModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation

class SubTaskModelController {
    
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
    
    func createSubTask(name: String, descriptor: String?, isCompleted: Bool = false, details: [Detail]?, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func fetchSubTasks() -> [SubTask] {
        
        // TODO: Finish implementation
        
        return [SubTask]()
    }
    
    func fetchSubTaskByIDName(idName: String) -> SubTask? {
        
        // TODO: Finish implementation
        
        return nil
    }
    
    func updateSubTask(subTask: SubTask, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func archiveSubTask(subTask: SubTask, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
        
        // TODO: Finish implementation
    }
}
