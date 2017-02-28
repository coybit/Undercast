//
//  PlayerViewController.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import AVFoundation
import Speech;


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

class PlayerViewController: UITableViewController, EpisodeDelegate {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var btnFastBackward: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var slideTime: UISlider!
    @IBOutlet weak var labelDuration: UILabel!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    var CurrentEpisode:Episode = Episode();
    var timerPlayerInfoUpdate:Timer!;
    var timerDownloaderUpdate:Timer!;
    var player:UnderPlayer = UnderPlayer();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let categoriesList = CurrentEpisode.categories;
        let categories = categoriesList.joined(separator: ",") + "\n-------\n";
        
        let authorsList = CurrentEpisode.authors?.map({ (a:Author) -> String in
            return "\(a.name)";
        })
        let authors = (authorsList?.joined(separator: "\n"))! + "\n-------\n";
        
        self.labelTitle.text = CurrentEpisode.title;
        self.txtDescription.text = authors + categories + CurrentEpisode.text;
        self.btnFastBackward.transform = CGAffineTransform(rotationAngle: 3.1415);
        
        CurrentEpisode.delegate = self;
        
        CurrentEpisode.podcast.loadCoverImageSync { (coverImage) in
        
            self.imgCover.image = coverImage;
            self.imgBackground.image = coverImage;
            
        }
        
        initPlayer();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPlayer() {
        
        if CurrentEpisode.isDownloaded() == false {
            
            let url = URL(string: self.CurrentEpisode.path);
            self.player = UnderPlayer(withURL: url!, isRemote: true);
            
        }
        else {
            
            //extractTextOfEpisode();
            
            self.player = UnderPlayer(withURL: self.CurrentEpisode.localPath()! as URL, isRemote: false);
            
        }
        
        if player.isReady == false {
            print("Something is wrong!");
        }
        
        if timerPlayerInfoUpdate != nil {
            timerPlayerInfoUpdate.invalidate();
        }
        
        timerPlayerInfoUpdate = Timer.scheduledTimer(timeInterval: 1 , target: self, selector: #selector(updatePlayerInfo), userInfo: nil, repeats: true);
    }
    
    func episodeDownloadingDidFinsh(_ error: NSError?) {
    }
    
    func updateDownloadProgressBar(_ userInfo: AnyObject) {
    }
    
    func updatePlayerInfo(_ userInfo: AnyObject)  {
        
        var duration = 0.0;
        var time = 0.0;
        
        self.slideTime.value = 0;
        
        if player.isReady {
            
            self.slideTime.value = Float(self.player.currentTime) / Float(self.player.duration);
            
            duration = self.player.duration;
            time = self.player.currentTime;
            
        }
        
        if CurrentEpisode.isDownloaded() {
            self.btnDownload.setTitle("Downloaded", for: UIControlState());
            self.btnDownload.isEnabled = false;
            self.btnDelete.isEnabled = true;
        }
        else {
            if CurrentEpisode.downloadingStatus == .Downloading {
                self.btnDownload.setTitle("Downloading", for: UIControlState());
                self.btnDownload.isEnabled = false;
                self.btnDelete.isEnabled = false;
            }
            else{
                self.btnDownload.setTitle("Download", for: UIControlState());
                self.btnDownload.isEnabled = true;
                self.btnDelete.isEnabled = false;
            }

        }
        
        self.labelDuration.text =  String(format: "%02.0f:%02.0f", duration/60, duration - Double(60*Int(duration/60)));
        self.labelCurrentTime.text = String(format: "%02.0f:%02.0f", time/60, time - Double(60*Int(time/60)));
    }
    
    @IBAction func FastForwardDidTouch(_ sender: AnyObject) {
        
        let delta = self.player.duration - self.player.currentTime;
        
        self.player.currentTime += min(delta, 5);
        
    }
    
    @IBAction func stopDidTouch(_ sender: AnyObject) {
        
        self.player.currentTime = 0;
        self.player.pause();
        
    }
    
    @IBAction func playPauseDidTouch(_ sender: AnyObject) {
        
        if self.player.playing {
            self.player.pause()
            self.btnPlay.setImage(UIImage(named: "ImagePlayerPlay"), for: UIControlState());
        }
        else {
            self.player.play();
             self.btnPlay.setImage(UIImage(named: "ImagePlayerPause"), for: UIControlState());
        }
        
    }

    @IBAction func downloadDidTouch(_ sender: AnyObject) {
        
        Downloader.sharedInstance.download(self.CurrentEpisode);

    }
    
    @IBAction func deleteDidTouch(_ sender: AnyObject) {
        
        player.pause();
        initPlayer();
        
        self.CurrentEpisode.deleteLocal();
        
    }
    
    @IBAction func timeSliderDidChange(_ sender: AnyObject) {
        
        self.player.currentTime = Double((sender as! UISlider).value) * self.player.duration;
        
    }
    
    
//    func extractTextOfEpisode() {
//        
//        SFSpeechRecognizer.requestAuthorization { (authState) in
//            
//            switch(authState) {
//            case .authorized:
//                    self.startEpisode2Text();
//            default: break
//            }
//            
//        }
//        
//    }
//    
//    var recognizer:SFSpeechRecognizer?;
//    var request:SFSpeechURLRecognitionRequest?;
//    
//    func startEpisode2Text() {
//        
//        recognizer = SFSpeechRecognizer()
//        
//        guard recognizer != nil else {
//            // Not supported for device's locale
//            return
//        }
//        if !(recognizer?.isAvailable)! {
//            // Not available right now
//            return
//        }
//        
//        let path = Bundle.main.path(forResource: "cast", ofType: "m4a")!;
//        let url = URL(fileURLWithPath: path);
//        
//        request = SFSpeechURLRecognitionRequest(url: url)
//        request?.shouldReportPartialResults = true
//        recognizer?.recognitionTask(with: request!) { (result, error) in
//            guard let result = result else {
//                // handle error
//                return
//            }
//            
//            print("File said \(result.bestTranscription.formattedString)")
//            
//            if result.isFinal {
//                print("File said \(result.bestTranscription.formattedString)")
//            }
//        }
//        
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
