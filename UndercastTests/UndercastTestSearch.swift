//
//  UndercastTests.swift
//  UndercastTests
//
//  Created by Malij on 3/7/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import XCTest
import Undercast

class UndercastTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRemoteAnswer() {

        let asyncExpectation = expectation(description: "longRunningFunction")
        
        let search = UCSearcher();
        search.Seach(term: "Awesome") { (podcasts) in
            
            XCTAssertNotEqual(podcasts.count, 0)
            
            asyncExpectation.fulfill();
            
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
}
