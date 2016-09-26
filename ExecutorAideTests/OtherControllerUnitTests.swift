//
//  OtherControllerUnitTests.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/26/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CloudKit
@testable import ExecutorAide

class OtherControllerUnitTests: XCTestCase {
    
    let cloudKitManager = CloudKitManager()
    
    //==================================================
    // MARK: - CloudKitManager
    //==================================================
    
    func testCheckCloudKitAvailability() {
        
        cloudKitManager.checkCloudKitAvailabilityStatus { (accountStatus) in
        
            XCTAssertEqual(accountStatus, CKAccountStatus.available, "The account status should be available (if you are signed in to CloudKit).")
        }
    }
}
