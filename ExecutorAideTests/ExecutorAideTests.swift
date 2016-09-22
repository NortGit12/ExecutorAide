//
//  ExecutorAideTests.swift
//  ExecutorAideTests
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import XCTest
@testable import ExecutorAide

class ExecutorAideTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //==================================================
    // MARK: - TestatorModelController
    //==================================================
    
    func testCreateTestator() {
        
        if let defaultTestatorImage = UIImage(named: "user"), let imageData = UIImagePNGRepresentation(defaultTestatorImage) {
        
            let testator = Testator(image: NSData(data: imageData), name: "Dean Norton")
            
            // Validate the Core Data record
            
            
            
            // Validate the CloudKit record
            
        }
    }
}
