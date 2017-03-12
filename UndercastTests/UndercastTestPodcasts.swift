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
    
    func testSubscribing() {
        
        let podcast = Podcast();
        podcast.title = "TestPodcast";
        podcast.link = "http://www.example.com";
        podcast.text = "Nothing";
        
        let podcasts = Podcasts();
        
        let n = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertEqual( podcasts.isSubscribed(podcast: podcast), false );
        
        XCTAssertEqual( podcasts.subscribe(podcast: podcast), true );
        
        XCTAssertEqual(podcasts.isSubscribed(podcast: podcast), true );
        
        let m = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertNotEqual(n, m);
        
        XCTAssertEqual( podcasts.unsubscribe(podcast: podcast), true );
        
        let p = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertEqual(n, p);
    }
    
    func testAddingEpisode() {
        
        let podcast = Podcast();
        podcast.title = "TestPodcast";
        podcast.link = "http://www.example.com";
        podcast.text = "Nothing";
    
        let e = Episode();
        e.podcast = podcast;
        e.title = "Title 1";
        e.text = "Description 111";
        e.duration = 100;
        e.path = "none";
        e.authors = nil;
        e.categories = ["none"];
        e.publishDate = Date();
        
        let n = podcast.episodes.count;
        
        podcast.addEpisode(episode: e);
    
        let m = podcast.episodes.count;
        
        XCTAssertEqual(m, n+1);
    
    }
    
}
