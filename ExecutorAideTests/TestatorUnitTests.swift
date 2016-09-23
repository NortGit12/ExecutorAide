//
//  TestatorUnitTests.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/22/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CloudKit
@testable import ExecutorAide

class TestatorUnitTests: XCTestCase {
    
//    let defaultImage = UIImage(named: "user")
    let defaultImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "user")!)!)
    let defaultName = "Unit Tester"
    
    //==================================================
    // MARK: - Basic Initializer
    //==================================================
    
    func testEmptyNameReturnsNil() {
        
        guard let _ = Testator(image: defaultImageData, name: "") else { return }
        
        XCTFail("The testator should not have been created.")
    }
    
    func testValidValuesReturnsInstance() {
        
        guard let testator = Testator(image: defaultImageData, name: defaultName) else {
            
            XCTFail("The testator could not be created.")
            return
        }
        
        XCTAssertNotNil(testator)
    }
    
    //==================================================
    // MARK: - Initializer from CloudKit record
    //==================================================
    
    func testInitializingWithoutAllExpectedValueFromCKRecordThatNilIsReturned() {
        
        // Create CKRecord, missing some data, or even empty
        let record = CKRecord(recordType: "Testator")
        
        guard let _ = Testator(record: record) else { return }
        
        XCTFail("The testator should not have been created.")
    }
    
    func testInitializingWithAllExpectedValueFromCKRecordThatAnInstanceIsReturned() {
        
        guard let originalTestator = Testator(image: defaultImageData, name: defaultName) else {
            
            XCTFail("The testator could not be created.")
            return
        }
        
        XCTAssertNotNil(originalTestator)
        
        if let originalTestatorCloudKitRecord = originalTestator.cloudKitRecord {
            
            guard let testatorCopy = Testator(record: originalTestatorCloudKitRecord) else {
                
                XCTFail("The testator should have been created.")
                return
            }
            
            XCTAssertNotNil(testatorCopy)
        }
    }
    
    //==================================================
    // MARK: - CloudKitRecord computed property
    //==================================================
    
    func testAllValuesStoredInCloudKitRecord() {
        
        guard let testator = Testator(image: defaultImageData, name: defaultName)
            , let testatorCloudKitRecord = testator.cloudKitRecord
            else {
            
            XCTFail("The testator could not be created.")
            return
        }
        
        XCTAssertNotNil(testator)
        
        guard let imageAssetData = testatorCloudKitRecord[Testator.imageKey] as? CKAsset
            , let imageDataFromCloudKitRecord = NSData(contentsOf: imageAssetData.fileURL)
            , let nameFromCloudKitRecord = testatorCloudKitRecord[Testator.nameKey] as? String
            else {
                
                XCTFail("The CloudKit values should have been accessble.")
                return
            }
        
        XCTAssertEqual(testator.image, imageDataFromCloudKitRecord)
        XCTAssertEqual(testator.name, nameFromCloudKitRecord)
    }
}


























