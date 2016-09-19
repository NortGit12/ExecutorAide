//
//  TaskModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation

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
    
    func createTask(name: String, subTasks: [SubTask]?, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func fetchTask() -> [Task] {
        
        // TODO: Finish implementation
        
        return [Task]()
    }
    
    func fetchTaskByIDName(idName: String) -> Task? {
        
        // TODO: Finish implementation
        
        return nil
    }
    
    func updateTask(task: Task, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func archiveTask(task: Task, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
        
        // TODO: Finish implementation
    }
}
