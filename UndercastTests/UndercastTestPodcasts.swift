//
//  UndercastTestPodcasts.swift
//  Undercast
//
//  Created by Malij on 3/8/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import XCTest
import Undercast

class UndercastTestPodcasts: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadSubscribedPodcastList() {
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        let podcasts = Podcasts();
        podcasts.loadSubscribedPodcast {
            
            asyncExpectation.fulfill();
            
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    
}