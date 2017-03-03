//
//  UnderPlayer.swift
//  Undercast
//
//  Created by Malij on 3/1/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import UIKit
import AVFoundation

class UnderPlayer : NSObject {
    
    fileprivate var remotePlayer:AVPlayer? = nil;
    fileprivate var localPlayer:AVAudioPlayer? = nil;
    fileprivate var isRemote:Bool
    
    var isReady:Bool {
        get {
            
            if !isRemote {
                
                if let _=localPlayer {
                    return true;
                }
                else{
                    return false;
                }
                
            }
            else {
                
                if let _=remotePlayer {
                    return true;
                }
                else{
                    return false;
                }
                
            }
            
        }
    }
    
    var currentTime:TimeInterval {
        get {
            if !isRemote {
                return (localPlayer?.currentTime)!;
            }
            else {
                return (remotePlayer?.currentTime().seconds)!;
            }
        }
        
        set {
            if !isRemote {
                localPlayer?.currentTime = newValue;
            }
            else {
                let time = CMTimeMakeWithSeconds(newValue,1);
                remotePlayer?.seek(to: time);
            }
        }
    }
    
    var duration:TimeInterval {
        get {
            if !isRemote {
                return (localPlayer?.duration)!;
            }
            else {
                let sec = CMTimeGetSeconds((remotePlayer?.currentItem?.duration)!);
                return sec.isNaN ? 0 : sec;
            }
            
        }
    }
    
    var playing:Bool {
        get {
            if !isRemote {
                return (localPlayer?.isPlaying)!;
            }
            else {
                if ((remotePlayer!.rate != 0) && (remotePlayer!.error == nil)) {
                    return true;
                }
                else {
                    return false;
                }
            }
        }
    }
    
    override init() {
        isRemote = false;
        super.init();
    }
    
    init(withURL url:URL, isRemote:Bool) {
        
        self.isRemote = isRemote;
        
        if isRemote {
            
            let playItem = AVPlayerItem(url: url);
            remotePlayer = AVPlayer(playerItem: playItem);
        }
        else {
            
            do{
                try localPlayer = AVAudioPlayer(contentsOf:url);
                localPlayer!.prepareToPlay();
            } catch
            {
                
            }
            
        }
        
    }
    
    func play() {
        if !isRemote {
            localPlayer?.play();
        }
        else {
            remotePlayer?.play();
        }
    }
    
    func pause() {
        if !isRemote {
            localPlayer?.pause();
        }
        else {
            remotePlayer?.pause();
        }
    }
    
}
