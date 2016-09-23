//
//  TestatorModelControllerSpec.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/22/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
import CoreData
@testable import ExecutorAide

class TestatorModelControllerSpec: XCTestCase {
    
    var controller: TestatorModelController!
    let defaultImage = UIImage(named: "user")
    let defaultName = "UnitTestDean Norton"
    
    override func setUp() {
        super.setUp()
        controller = TestatorModelController.shared
    }
    
    func testThatATestatorIsCreatedProperly() {
        
        guard let testator = Testator(image: NSData(data: UIImagePNGRepresentation(defaultImage!)!), name: defaultName) else {
            
            XCTFail("The testator could not be created.")
            return
        }
        
        // Validate instance creation
        
        XCTAssertNotNil(testator)
        
        // Validate existence in Core Data
        
        // Validate existence in CloudKit
        
        // Cleanup
        
        TestatorModelController.shared.deleteTestator(testator: testator)
    }
    
}
