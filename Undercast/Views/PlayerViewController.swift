//
//  PlayerViewController.swift
//  Undercast
//
//  Created by coybit on 9/10/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import Speech;
import SDWebImage
import ChameleonFramework
import MarkedView

class PlayerViewController: UITableViewController, EpisodeDelegate {

    @IBOutlet weak var markdownDescription: UIMarkedView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
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

        self.setStatusBarStyle(UIStatusBarStyleContrast)
        self.navigationController?.hidesNavigationBarHairline = true;
        self.navigationController?.navigationBar.barTintColor = UIColor.flatOrange();
        
        let categoriesList = CurrentEpisode.categories;
        let categories = categoriesList.joined(separator: ",") + "\n\n";
        
        let authorsList = CurrentEpisode.authors?.map({ (a:Author) -> String in
            return "\(a.name)";
        })
        let authors = (authorsList?.joined(separator: "\n"))! + "\n\n";
        
        self.labelTitle.text = CurrentEpisode.title;
        self.markdownDescription.textToMark( authors + categories + CurrentEpisode.text );
        self.btnFastBackward.transform = CGAffineTransform(rotationAngle: 3.1415);

        CurrentEpisode.podcast.coverImageURL { (url) in
            
            self.imgCover.sd_setImage(with: url);
            self.imgBackground.sd_setImage(with: url);
            
        }
        
        btnDownload.isEnabled = CurrentEpisode.isDownloaded();
        
        NotificationCenter.default.addObserver(forName: UCNotificationReplicationStatusDidChange, object: nil, queue: OperationQueue.main) { (notif) in
            
           self.btnDownload.isEnabled = self.CurrentEpisode.isDownloaded();
            
        }
        
        CurrentEpisode.delegate = self;
        
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
        
        self.CurrentEpisode.download();
    }
    
    @IBAction func deleteDidTouch(_ sender: AnyObject) {
        
        player.pause();
        initPlayer();
        
        self.CurrentEpisode.deleteLocal();
        
    }
    
    @IBAction func timeSliderDidChange(_ sender: AnyObject) {
        
        self.player.currentTime = Double((sender as! UISlider).value) * self.player.duration;
        
    }
    

}
