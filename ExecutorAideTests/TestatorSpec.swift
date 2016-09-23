//
//  TestatorSpec.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/22/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CloudKit
@testable import ExecutorAide

class TestatorSpec: XCTestCase {
    
    func testThatItReturnsNilWhenInitializingWithoutAllExpectedValueFromCKRecord() {
        // Create CKRecord, missing some data, or even empty
        let record = CKRecord(recordType: "Testator")
        let testator = Testator(record: record)
        XCTAssertNil(testator)
    }
    
}
