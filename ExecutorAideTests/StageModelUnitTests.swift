//
//  StageUnitTests.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/23/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CloudKit
@testable import ExecutorAide

class StageModelUnitTests: XCTestCase {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    let defaultTestatorImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "user")!)!)
    let defaultTestatorName = "Unit Test TestatorName"
    
    let defaultStageDescriptor = "Unit Test StageDescriptor"
    let defaultStageName = "Unit Test StageName"
    let defaultStagePercentComplete: Float = 0.0
    let defaultStageSortValue: Int = 0
    
    //==================================================
    // MARK: - Basic Initializer
    //==================================================
    
    func testEmptyDescriptorReturnsNil() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let _ = Stage(descriptor: "", name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            else { return }
        
        XCTFail("The Stage should not have been created.")
    }
    
    func testEmptyNameReturnsNil() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let _ = Stage(descriptor: defaultStageDescriptor, name: "", percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            else { return }
        
        XCTFail("The Stage should not have been created.")
    }
    
    func testOutOfRangeLowPercentCompleteReturnsNil() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let _ = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: -0.1, sortValue: defaultStageSortValue, testator: testator)
            else { return }
        
        XCTFail("The Stage should not have been created.")
    }
    
    func testOutOfRangeHighPercentCompleteReturnsNil() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let _ = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: 1.1, sortValue: defaultStageSortValue, testator: testator)
            else { return }
        
        XCTFail("The Stage should not have been created.")
    }
    
    func testValidValuesReturnsInstance() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            else {
            
            XCTFail("The Stage could not be created.")
            return
        }
        
        XCTAssertNotNil(stage)
    }
    
    //==================================================
    // MARK: - Initializer from CloudKit record
    //==================================================
    
    func testInitializingWithoutAllExpectedValueFromCKRecordThatNilIsReturned() {
        
        // Create CKRecord, missing some data, or even empty
        let record = CKRecord(recordType: Stage.type)
        
        guard let _ = Stage(record: record) else { return }
        
        XCTFail("The Stage should not have been created.")
    }
    
    func testInitializingWithAllExpectedValueFromCKRecordThatAnInstanceIsReturned() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let originalStage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            else {
            
            XCTFail("The Stage could not be created.")
            return
        }
        
        if let originalStageCloudKitRecord = originalStage.cloudKitRecord {
            
            guard let stageCopy = Stage(record: originalStageCloudKitRecord) else {
                
                XCTFail("The Stage should have been created.")
                return
            }
            
            XCTAssertNotNil(stageCopy)
        }
    }
    
    //==================================================
    // MARK: - CloudKitRecord computed property
    //==================================================
    
    func testAllValuesStoredInCloudKitRecord() {
        
        guard let testator = Testator(image: defaultTestatorImageData, name: defaultTestatorName)
            , let stage = Stage(descriptor: defaultStageDescriptor, name: defaultStageName, percentComplete: defaultStagePercentComplete, sortValue: defaultStageSortValue, testator: testator)
            , let stageCloudKitRecord = stage.cloudKitRecord
            else {
                
                XCTFail("The Stage could not be created.")
                return
        }
        
        guard let descriptor = stageCloudKitRecord[Stage.descriptorKey] as? String
            , let name = stageCloudKitRecord[Stage.nameKey] as? String
            , let percentComplete = stageCloudKitRecord[Stage.percentCompleteKey] as? Float
            , let sortValue = stageCloudKitRecord[Stage.sortValueKey] as? Int
            , let testatorReference = stageCloudKitRecord[Stage.testatorKey] as? CKReference
            else {
                
                XCTFail("The CloudKit values should have been accessble.")
                return
        }
        
        XCTAssertEqual(stage.descriptor, descriptor)
        XCTAssertEqual(stage.name, name)
        XCTAssertEqual(stage.percentComplete, percentComplete)
        XCTAssertEqual(stage.sortValue, sortValue)
        
        let testatorIDName = testatorReference.recordID.recordName
        guard let parentTestator = TestatorModelController.shared.fetchTestatorByIDName(idName: testatorIDName) else {
            
            XCTFail("The Stage's Testator should have been found.")
            return
        }
        
        XCTAssertEqual(stage.testator, parentTestator)
    }
}
