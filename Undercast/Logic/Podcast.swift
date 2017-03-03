//
//  Podcast.swift
//  Undercast
//
//  Created by coybit on 9/14/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import CoreData;

let UCNotificationSubscribtionsListDidChange = NSNotification.Name(rawValue: "subscribtionsListDidChange");

class Podcast: NSObject {

    var title:String = "";
    var link:String = "";
    var text:String = "";
    var foundCoverImgURL:String?;
    var episodes:[Episode] = [];
    var lastFeed:String = "";
    static let lockQueue = DispatchQueue(label: "com.test.LockQueue", attributes: [])
    static let downloadQueue = OperationQueue();
    
    func addEpisode(episode:Episode) {
        
        let has = episodes.contains { (e) -> Bool in
            return e.path == episode.path;
        }
        
        if has == false {
            episodes.append(episode);
        }
    }
    
    func load() {
        
        loadFromLocal();
        loadFromRemote();
        
    }
    
    func parseFeed(feed:String) {
        
        let parser = FeedParser(string:feed);
        
        parser.success({ (feed) in
            
            //let podcast = Podcast();
            self.title = feed.title;
            self.text = feed.description;
            self.link = feed.link.absoluteString;
            self.foundCoverImgURL = (feed.imageURL?.absoluteString)!;
            
            for article in feed.articles {
                
                guard article.enclosures.count > 0 &&
                    article.title != "" else {
                        continue;
                }
                
                let e = Episode();
                e.podcast = self;
                e.title = article.title;
                e.text = article.description;
                e.duration = article.duration;
                e.path = (article.enclosures.first?.url.absoluteString)!;
                e.authors = article.authors;
                e.categories = article.categories;
                e.publishDate = article.published;
                
                self.addEpisode(episode: e);
                
            }
            
        })
        parser.failure {
            print("Failed to parse: \($0)")
        }
        
        parser.main()
    }
    
    func loadFromRemote() {
        
        
        do {
            let RSSUrl = URL(string: self.link);
            let RSSFeed = try String(contentsOf:RSSUrl!, encoding: String.Encoding.utf8)
            
            save(theLastFeed: RSSFeed);
            
            parseFeed(feed: RSSFeed);
            
        }catch{}
        
        
    }
    
    func save(theLastFeed feed:String) {
        
        guard let moc = managedObjectContext() else {
            return;
        }
        
        do {
            
            let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
            fetch.predicate = NSPredicate(format: "pfeedUrl=%@", self.link);
            let results = try moc.fetch(fetch) as! [EntitySubscribedPodcast];
            
            if results.count > 0 {
                results.first?.plastfeed = feed;
                try moc.save();
            }
            
        } catch {}
    }
    
    func loadFromLocal() {
        
        parseFeed(feed: self.lastFeed);
    
    }
    
    var coverImgURL:URL {
        
        get {
            
//            if foundCoverImgURL != nil {
//                return URL(string:foundCoverImgURL!)!;
//            }
//        
//            let rssParser = XMLParser(contentsOfURL: URL(string:self.link as String)! );
//            
//            foundCoverImgURL = rssParser.valueForPath("rss/channel/image/url");
//            
//            if foundCoverImgURL == nil {
//                
//                foundCoverImgURL = rssParser.valueForAttribute("rss/channel/itunes:image", attribute: "href");
//                
//            }
//            
//            return URL(string:foundCoverImgURL!)!;

            return URL(string: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")!;
        }
    }
    
    func cancelLoadingImage() {
        
    }
    
    func isSubscribed() -> Bool {
        
        guard let moc = managedObjectContext() else {
            return false;
        }
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        fetch.predicate = NSPredicate(format: "pfeedUrl=%@", link);
        
        do {
            let results = try moc.fetch(fetch);
            return results.count > 0;
        } catch {}
        
        return false;
    }
    
    
    func subscribe() {
        
        guard let moc = managedObjectContext() else {
            return;
        }
        
        let p:EntitySubscribedPodcast = NSManagedObject(entity: entityDescription()!, insertInto: managedObjectContext()!) as! EntitySubscribedPodcast;
        
        p.setValue(self.title, forKey: "ptitle");
        p.setValue(self.text, forKey: "pdescription");
        p.setValue(self.link, forKey: "pfeedUrl");
        
        do { try moc.save(); }
        catch {}
        
        NotificationCenter.default.post(name: UCNotificationSubscribtionsListDidChange, object: nil);
    }
    
    
    func unsubscribe() {
        
        guard let moc = managedObjectContext() else {
            return;
        }
        
        let fetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntitySubscribedPodcast");
        fetch.predicate = NSPredicate(format: "pfeedUrl=%@", self.link);
        
        do {
            let results = try moc.fetch(fetch) as! [NSManagedObject];
            
            for r in results {
                moc.delete(r);
            }
            
            try moc.save();
            
        } catch {}
        
        NotificationCenter.default.post(name: UCNotificationSubscribtionsListDidChange, object: nil);
    }
    
    func managedObjectContext() -> NSManagedObjectContext? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        return appDelegate.managedObjectContext;
        
    }
    
    func entityDescription () -> NSEntityDescription? {
        
        return NSEntityDescription.entity(forEntityName: "EntitySubscribedPodcast", in: managedObjectContext()!);
        
    }
}
