//
//  Podcasts.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import CoreData;

class Podcasts: NSObject {

    var episodes: [Episode];
    var filteredEpisodes: [Episode];
    var filterMinTime: Int;
    var filterMaxTime: Int;
    private var subscribedPodcastsList:[Podcast] = [];
    static let shared = Podcasts();
    
    override init() {
        
        episodes = [];
        filteredEpisodes = [];
        
        filterMinTime = 0;
        filterMaxTime = Int.max;
    }
    
    func numberOfEpisodes() -> Int {
        return filteredEpisodes.count;
    }
    
    func numberOfSubscribedPodcasts() -> Int {
        return subscribedPodcastsList.count;
    }
    
    func setFilter(_ minTime:Int, maxTime:Int) {
        filterMinTime = minTime;
        filterMaxTime = maxTime;
        
        filteredEpisodes.removeAll();
        
        for pod in subscribedPodcastsList {
        
            for eps in pod.episodes {
                
                if( eps.duration > filterMinTime && eps.duration < filterMaxTime ) {
                    
                    filteredEpisodes.append(eps);
                }
                
            }
            
        }
        
        let mid = Float(filterMinTime + filterMaxTime) / 2;
        
        filteredEpisodes = filteredEpisodes.sorted { (e1, e2) -> Bool in
            let d1 = abs(Float(e1.duration)-mid);
            let d2 = abs(Float(e2.duration)-mid);
            
            if d1 == d2 {
                return e1.publishDate!.compare( e2.publishDate! as Date ) == .orderedDescending;
            }
            else {
                return d1 <= d2;
            }
        };
    }
    
    func episodeAtIndex(_ index: Int) -> Episode? {
        
        if index >= filteredEpisodes.count {
            return nil;
        }
        else {
            return filteredEpisodes[index];
        }
    }
    
    func loadSubscribedPodcast() {
        
        let queue = OperationQueue();
        queue.qualityOfService = .userInitiated;
        queue.maxConcurrentOperationCount = 4;
        
        subscribedPodcastsList = subscribedPodcasts();
        
        for podcast in subscribedPodcastsList {
        
            queue.addOperation({ 
               
                podcast.load();
                
            });
            
        }
        
    }
    
    func podcastAtIndex(index:Int) -> Podcast {
        return subscribedPodcastsList[index];
    }
    
    func subscribedPodcasts() -> [Podcast] {
        
        guard let moc = managedObjectContext() else {
            return [];
        }
        
        subscribedPodcastsList = [];
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        
        do {
            let results = try moc.fetch(fetch) as! [EntitySubscribedPodcast];
            
            for r in results {
                let p = Podcast();
                p.title = r.ptitle!;
                p.text = r.pdescription!;
                p.link = r.pfeedUrl!;
                p.lastFeed = r.plastfeed ?? "";
                subscribedPodcastsList.append(p);
            }
            
        } catch {}
        
        return subscribedPodcastsList;
    }
    

    
    func managedObjectContext() -> NSManagedObjectContext? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        return appDelegate.managedObjectContext;
        
    }
    
    func entityDescription () -> NSEntityDescription? {
        
        return NSEntityDescription.entity(forEntityName: "EntitySubscribedPodcast", in: managedObjectContext()!);
        
    }

}
