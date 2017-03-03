//
//  Downloader.swift
//  Undercast
//
//  Created by coybit on 9/19/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

let NCDownloadListDidChange = "DLDC";

enum DownloadStatus : String {
    case Not = "Not"
    case Downloading = "Downloading"
    case Failed = "Failed"
    case Completed = "Completed"
    case Paused = "Paused"
}

class DownloadItem: NSObject {
    
    var URL:Foundation.URL?;
    var title:String?;
    var progress:Float = 0;
    var task:URLSessionTask?;
}

class UCDownloader: NSObject, URLSessionDelegate {

    static let sharedInstance = UCDownloader();
    fileprivate var episodeList:[String:Episode] = [:];
    fileprivate var taskList:[String:URLSessionTask] = [:];
    
    
    override init() {
    }
    
    fileprivate func save() {
        // ToDo: Save list on storage
    }
    
    fileprivate func findEpisodeByTask(_ task:URLSessionTask) -> Episode! {
        
        for t in taskList {
            if t.1 == task {
                return episodeList[t.0];
            }
        }
        return nil;
    }
    
    fileprivate func findEpisodeByURL(_ url:String) -> Episode! {
        
        let key = url.md5();
        let episode = episodeList[key];
        return episode;
        
    }
    
    func itemAtIndex(_ index:Int) -> Episode? {
        
        let key = Array(episodeList.keys)[index];
        return episodeList[key];
        
    }
    
    func downoadList() -> [String:Episode] {
        return episodeList;
    }
    
    func stopAll() {
        
        for eps in episodeList.values {
            
            stop(eps.downloadID!);
            
        }
        
    }
    
    func stop(_ downlaodID:String) {
        
        if episodeList.index(forKey: downlaodID) == nil {
            return;
        }
        
        episodeList[downlaodID]!.downloadingStatus = .Paused;
        taskList[downlaodID]!.suspend();
        
        broadcastChangInDownloads();
    }
    
    func restart(_ downlaodID:String) {
        
        if episodeList.index(forKey: downlaodID) == nil {
            return;
        }
        
        episodeList[downlaodID]!.downloadingStatus = .Downloading;
        taskList[downlaodID]!.resume();
        
        broadcastChangInDownloads();
    }
    
    func download(_ episode:Episode)  {
        
        // Prevent duplication
        let eps = findEpisodeByURL(episode.path);
        if eps != nil {
            
            if taskList[ (eps?.path.md5())! ]?.state == .running {
                
                return;
                
            }
            
        }
        
        
        
        let configuration = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: URL(string:episode.path)!);
        
        let key = episode.path.md5();
        
        episodeList[key] = episode;
        taskList[key] = task;
        
        task.resume();
        
        episode.downloadingStatus = .Downloading;
        episode.downloadID = key;
        
        broadcastChangInDownloads();
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        
        //if self.delegate != nil {
        //    self.delegate?.episodeDownloadingDidFinsh(error);
        //}
        
        let eps = findEpisodeByTask(task);
        guard eps != nil else { return; }
        
        if error == nil {
            eps?.downloadingStatus = .Completed;
        }
        else {
            eps?.downloadingStatus = .Failed;
        }
        
        //let key = eps.path.md5();
        //taskList.removeValueForKey(key)
        //episodeList.removeValueForKey(key);
        
        broadcastChangInDownloads();
    }
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        
        let episode = findEpisodeByTask(downloadTask);
        guard episode != nil else {return;}
        
        let dstPath = episode?.localPath();
        guard dstPath != nil else {return;}
        
        
        do{
            try FileManager.default.moveItem(at: location, to:
                dstPath! as URL);
        } catch{}
        
    }
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let episode = findEpisodeByTask(downloadTask);
        guard episode != nil else {return;}
        
        episode?.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite);
     
        broadcastChangInDownloads();
    }
    
    func broadcastChangInDownloads() {
        NotificationCenter.default.post(name: UCNotificationReplicationStatusDidChange, object: nil);
    }
}
