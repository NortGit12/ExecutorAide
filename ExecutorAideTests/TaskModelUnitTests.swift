//
//  TaskModelUnitTests.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/26/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CloudKit
@testable import ExecutorAide

class TaskModelUnitTests: XCTestCase {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    let defaultTestatorImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "user")!)!)
    let defaultTestatorName = "Unit Test TestatorName"
    
    let defaultStageDescriptor = "Unit Test StageDescriptor"
    let defaultStageName = "Unit Test StageName"
    let defaultStagePercentComplete: Float = 0.0
    let defaultStageSortValue: Int = 0
    
    let defaultTaskName = "Unit Test TaskName"
    let defaultTaskSortValue: Int = 0
    
    //==================================================
    // MARK: - Basic Initializer
    //==================================================
    
    func testEmptyNameReturnsNil() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            , let _ = Task(name: "", sortValue: defaultTaskSortValue, stage: stage)
            else { return }
        
        XCTFail("The Task should not have been created.")
    }
    
    func testValidValuesReturnsInstance() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            , let task = Task(name: defaultTaskName, sortValue: defaultTaskSortValue, stage: stage)
            else {
                
                XCTFail("The Task could not be created.")
                return
        }
        
        XCTAssertNotNil(task)
    }
    
    //==================================================
    // MARK: - Initializer from CloudKit record
    //==================================================
    
    func testInitializingWithoutAllExpectedValueFromCKRecordThatNilIsReturned() {
        
        // Create CKRecord, missing some data, or even empty
        let record = CKRecord(recordType: Task.type)
        
        guard let _ = Task(record: record) else { return }
        
        XCTFail("The Task should not have been created.")
    }
    
    func testInitializingWithAllExpectedValueFromCKRecordThatAnInstanceIsReturned() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            , let originalTask = Task(name: defaultTaskName, sortValue: defaultTaskSortValue, stage: stage)
            else {
                
                XCTFail("The Task could not be created.")
                return
        }
        
        if let originalTaskCloudKitRecord = originalTask.cloudKitRecord {
            
            guard let taskCopy = Task(record: originalTaskCloudKitRecord) else {
                
                XCTFail("The Task should have been created.")
                return
            }
            
            XCTAssertNotNil(taskCopy)
        }
    }
    
    //==================================================
    // MARK: - CloudKitRecord computed property
    //==================================================
    
    func testAllValuesStoredInCloudKitRecord() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            , let task = Task(name: defaultTaskName, sortValue: defaultTaskSortValue, stage: stage)
            , let taskCloudKitRecord = task.cloudKitRecord
            else {
                
                XCTFail("The Task could not be created.")
                return
        }
        
        guard let name = taskCloudKitRecord[Task.nameKey] as? String
            , let sortValue = taskCloudKitRecord[Task.sortValueKey] as? Int
            , let stageReference = taskCloudKitRecord[Task.stageKey] as? CKReference
            else {
                
                XCTFail("The CloudKit values should have been accessble.")
                return
        }
        
        XCTAssertEqual(task.name, name)
        XCTAssertEqual(task.sortValue, sortValue)
        
        let stageIDName = stageReference.recordID.recordName
        guard let parentStage = StageModelController.shared.fetchStageByIDName(idName: stageIDName) else {
            
            XCTFail("The Task's Stage should have been found.")
            return
        }
        
        XCTAssertEqual(task.stage, parentStage)
    }
}
























