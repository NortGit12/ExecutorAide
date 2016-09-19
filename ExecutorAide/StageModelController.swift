//
//  StageModelController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation

class StageModelController {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let shared = StageModelController()
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
    
    func createStage(name: String, descriptor: String, percentComplete: Float = 0.0, tasks: [Task], completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func fetchStages() -> [Stage] {
        
        // TODO: Finish implementation
        
        return [Stage]()
    }
    
    func fetchStageByIDName(idName: String) -> Stage? {
        
        // TODO: Finish implementation
        
        return nil
    }
    
    func updateStage(stage: Stage, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    func deleteStage(stage: Stage, completion: (() -> Void)? = nil) {
        
        // TODO: Finish implementation
    }
    
    //==================================================
    // MARK: - Methods (other)
    //==================================================
    
    func createInitialDataSet() {
        
        // TODO: Finish implementation
    }
}
