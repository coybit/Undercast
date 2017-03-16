//
//  Episode.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

public protocol EpisodeDelegate : class {
    func episodeDownloadingDidFinsh(_ error:NSError?);
}

let UCNotificationReplicationStatusDidChange = NSNotification.Name(rawValue: "ReplicationStatusDidChange");

public class Episode: NSObject {

    public var title = "";
    public var path = "";
    public var podcast:Podcast;
    public var duration:Int;
    public var text = "";
    public var authors:[Author]?;
    public var categories:[String] = []
    public var publishDate:Date?;
    
    public var downloadProgress:Float = 0;
    public var downloadingStatus:DownloadStatus;
    public var downloadID:String?;
    
    public weak var delegate:EpisodeDelegate?;
    
    
    public override init() {
        
        title = "";
        podcast = Podcast();
        duration = 0;
        downloadingStatus = .Not;
        
    }
    
    public func localPath() -> URL? {
        let hash = self.path.md5();
        let filePath = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(hash)
        return filePath;
    }
    
    func download() {
        UCDownloader.sharedInstance.download(self);
    }
    
    public func isDownloaded() -> Bool {
        
        let filePath = localPath();
        
        guard filePath != nil else {
            return false;
        }
        
        if FileManager.default.fileExists(atPath: filePath!.path) {
            return true;
        }
        
        return false;
        
    }
    
    func deleteLocal() {
        
        if FileManager.default.fileExists(atPath: (localPath()?.path)!) {
            
            do{ try FileManager.default.removeItem(at: localPath()!); }
            catch{}
            
            NotificationCenter.default.post(name: UCNotificationReplicationStatusDidChange, object: nil);
        }
        
    }
    
}
