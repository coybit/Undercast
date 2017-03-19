//
//  Podcasts.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import CoreData;

public class Podcasts: NSObject {

    var isReady = false;
    var episodes: [Episode];
    var filteredEpisodes: [Episode];
    var filterMinTime: Int;
    var filterMaxTime: Int;
    private var cachedSubscribedPodcastsList:[Podcast] = [];
    static let shared = Podcasts();
    
    public override init() {
        
        episodes = [];
        filteredEpisodes = [];
        
        filterMinTime = 0;
        filterMaxTime = Int.max;
    }
    
    public func numberOfEpisodes() -> Int {
        checkForBeingReady();
        
        return filteredEpisodes.count;
    }
    
    public func numberOfSubscribedPodcasts() -> Int {
        checkForBeingReady();
        
        return cachedSubscribedPodcastsList.count;
    }
    
    public func setFilter(minTime:Int, maxTime:Int) {
        checkForBeingReady();
        
        filterMinTime = minTime;
        filterMaxTime = maxTime;
        
        filteredEpisodes.removeAll();
        
        for pod in cachedSubscribedPodcastsList {
        
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
    
    public func episodeAtIndex(_ index: Int) -> Episode? {
        checkForBeingReady();
        
        if index >= filteredEpisodes.count {
            return nil;
        }
        else {
            return filteredEpisodes[index];
        }
    }
    
    public func podcastAtIndex(index:Int) -> Podcast {
        checkForBeingReady();
        
        return cachedSubscribedPodcastsList[index];
    }
    
    private func subscribedPodcasts() -> [Podcast] {

        guard let moc = managedObjectContext() else {
            return [];
        }
        
        cachedSubscribedPodcastsList = [];
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        
        do {
            let results = try moc.fetch(fetch) as! [EntitySubscribedPodcast];
            
            for r in results {
                let p = Podcast();
                p.title = r.ptitle!;
                p.text = r.pdescription!;
                p.link = r.pfeedUrl!;
                p.lastFeed = r.plastfeed ?? "";
                cachedSubscribedPodcastsList.append(p);
            }
            
        } catch {}
        
        return cachedSubscribedPodcastsList;
    }
    
    public func isSubscribed(podcast:Podcast) -> Bool {

        guard let moc = managedObjectContext() else {
            return false;
        }
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        fetch.predicate = NSPredicate(format: "pfeedUrl=%@", podcast.link);
        
        do {
            let results = try moc.fetch(fetch);
            return results.count > 0;
        } catch {}
        
        return false;
    }
    
    public func subscribe(podcast:Podcast) -> Bool {

        if isSubscribed(podcast: podcast) == true {
            return true;
        }
        
        guard let moc = managedObjectContext() else {
            return false;
        }
        
        let p:EntitySubscribedPodcast = NSManagedObject(entity: entityDescription()!, insertInto: managedObjectContext()!) as! EntitySubscribedPodcast;
        
        p.setValue(podcast.title, forKey: "ptitle");
        p.setValue(podcast.text, forKey: "pdescription");
        p.setValue(podcast.link, forKey: "pfeedUrl");
        
        do { try moc.save(); }
        catch {
            return false;
        }
        
        NotificationCenter.default.post(name: UCNotificationSubscribtionsListDidChange, object: nil);
        
        cachedSubscribedPodcastsList.append(podcast);
        
        return true;
    }
    
    public func unsubscribe(podcast:Podcast) -> Bool {
        checkForBeingReady();
        
        guard let moc = managedObjectContext() else {
            return false;
        }
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        fetch.predicate = NSPredicate(format: "pfeedUrl=%@", podcast.link);
        
        do {
            let results = try moc.fetch(fetch) as! [NSManagedObject];
            
            for r in results {
                moc.delete(r);
            }
            
            try moc.save();
            
        } catch {
            return false;
        }
        
        NotificationCenter.default.post(name: UCNotificationSubscribtionsListDidChange, object: nil);
        
        if let idx = cachedSubscribedPodcastsList.index(of: podcast) {
            cachedSubscribedPodcastsList.remove(at: idx);
        }
        
        return true;
    }
    
    private func checkForBeingReady() {
        assert(isReady, "You have to call loadSubscribedPodcast and wait till it calls your callback");
    }
    
    public func loadSubscribedPodcast(callback:@escaping (()->Void)) {
        
        let queue = OperationQueue();
        
        queue.qualityOfService = .userInitiated;
        queue.maxConcurrentOperationCount = 4;
        
        cachedSubscribedPodcastsList = subscribedPodcasts();
        var remaindedPodcast = cachedSubscribedPodcastsList.count;
        
        if remaindedPodcast == 0 {
            isReady = true;
            callback();
        }
        else {
            
            let semaphore = DispatchSemaphore(value: 1);
            
            for podcast in cachedSubscribedPodcastsList {
                
                queue.addOperation({
                    
                    podcast.load();
                    
                    semaphore.wait();
                    remaindedPodcast -= 1;
                    if remaindedPodcast <= 0 {
                        self.isReady = true;
                        callback();
                    }
                    semaphore.signal();
                });
                
            }
            
        }
        
    }
    
    func managedObjectContext() -> NSManagedObjectContext? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        return appDelegate.managedObjectContext;
        
    }
    
    func entityDescription () -> NSEntityDescription? {
        
        return NSEntityDescription.entity(forEntityName: "EntitySubscribedPodcast", in: managedObjectContext()!);
        
    }

}
