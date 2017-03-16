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
    
    var stubPodcast:Podcast!;
    var stubEpisode:Episode!;
    
    override func setUp() {
        super.setUp()
        
        stubPodcast = Podcast();
        stubPodcast.title = "TestPodcast";
        stubPodcast.link = "http://www.example.com/\(arc4random())";
        stubPodcast.text = "Nothing";

        stubEpisode = Episode();
        stubEpisode.podcast = stubPodcast;
        stubEpisode.title = "Title 1";
        stubEpisode.text = "Description 111";
        stubEpisode.duration = 100;
        stubEpisode.path = "none";
        stubEpisode.authors = nil;
        stubEpisode.categories = ["none"];
        stubEpisode.publishDate = Date();
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
        
        let podcasts = Podcasts();
        
        let n = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertEqual( podcasts.isSubscribed(podcast: stubPodcast), false );
        
        XCTAssertEqual( podcasts.subscribe(podcast: stubPodcast), true );
        
        XCTAssertEqual(podcasts.isSubscribed(podcast: stubPodcast), true );
        
        let m = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertNotEqual(n, m);
        
        XCTAssertEqual( podcasts.unsubscribe(podcast: stubPodcast), true );
        
        let p = podcasts.numberOfSubscribedPodcasts();
        
        XCTAssertEqual(n, p);
    }
    
    func testAddingEpisode() {
        
        let n = stubPodcast.episodes.count;
        
        stubPodcast.addEpisode(episode: stubEpisode);
        
        let m = stubPodcast.episodes.count;
        
        XCTAssertEqual(m, n+1);
        
        let podcasts = Podcasts();
        
        XCTAssertTrue(podcasts.subscribe(podcast: stubPodcast));
        
        podcasts.setFilter(0, maxTime: 10000);
        
        XCTAssertGreaterThanOrEqual(podcasts.numberOfSubscribedPodcasts(),1);
        XCTAssertGreaterThanOrEqual(podcasts.numberOfEpisodes(),1);
        
        let episode = podcasts.episodeAtIndex(0);
        
        XCTAssertNotNil(episode);
        
        XCTAssertNotNil(episode?.localPath());
    }
}
