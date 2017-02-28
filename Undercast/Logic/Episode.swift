//
//  Episode.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

protocol EpisodeDelegate : class {
    func episodeDownloadingDidFinsh(_ error:NSError?);
}

class Episode: NSObject {

    var title = "";
    var path = "";
    var podcast:Podcast;
    var duration:Int;
    var text = "";
    var authors:[Author]?;
    var categories:[String] = []
    var publishDate:Date?;
    
    var downloadProgress:Float = 0;
    var downloadingStatus:DownloadStatus;
    var downloadID:String?;
    weak var delegate:EpisodeDelegate?;
    
    
    override init() {
        
        title = "";
        podcast = Podcast();
        duration = 0;
        downloadingStatus = .Not;
        
    }
    
    func localPath() -> URL? {
        let hash = self.path.md5();
        let filePath = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(hash)
        return filePath;
    }
    
    func isDownloaded() -> Bool {
        
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
            
        }
        
    }
    
}
