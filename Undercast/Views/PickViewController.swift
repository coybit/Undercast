//
//  ViewController.swift
//  Undercast
//
//  Created by coybit on 9/9/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MBProgressHUD
import SDWebImage
import ChameleonFramework

class PickViewController: UnderViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource  {

    @IBOutlet weak var conFilterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableEpisodes: UITableView!
    @IBOutlet weak var sliderTime: UISlider!
    @IBOutlet weak var labelTimeMin: UILabel!
    @IBOutlet weak var labelTimeSec: UILabel!
    @IBOutlet weak var labelUnit: UILabel!
    @IBOutlet weak var labelDifference: UILabel!

    var podcasts:Podcasts = Podcasts.shared;
    var queue:OperationQueue = OperationQueue();
    let semaphore = DispatchSemaphore(value: 4)
    var filterViewIsExpanded = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        queue.qualityOfService = .userInitiated;
        
        updateSubscribedPostcastsList();
        self.updateTimeLabel();
        
        // A little trick for removing the cell separators
        tableEpisodes.tableFooterView = UIView();

        
        NotificationCenter.default.addObserver(forName: UCNotificationSubscribtionsListDidChange,
                                               object: nil,
                                               queue: OperationQueue.main) { (notif) in
            
            self.updateSubscribedPostcastsList();
            
        }
    }

    func updateSubscribedPostcastsList() {
        
        podcasts.loadSubscribedPodcast {
            OperationQueue.main.addOperation {
                self.updateList();
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderTimeDidChange(_ sender: AnyObject) {
        
        self.updateTimeLabel();
        self.updateList();
        
    }
    
    func updateList() {
        let time = self.convertSliderToMinute();
        let sec = time.min * 60 + time.sec;
        podcasts.setFilter(Int(sec - 0.5 * sec), maxTime: Int(sec + 0.5 * sec) );
        self.tableEpisodes.reloadData();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "seguePlay" {
            
            if sender != nil {
                let vc = segue.destination as! PlayerViewController;
                vc.CurrentEpisode = sender as! Episode;
            }
        }
        
    }
    
    func convertSliderToMinute() -> (min:Float,sec:Float) {
        let x = 10 * self.sliderTime.value;
        let t = x * x + 1;
        let nt = floor(t);
        var d = t - nt;
        
        if nt < 5 {
            d = 15 * floor(d*4);
        }
        else if nt < 10 {
            d = 30 * floor(d*2);
        }
        else {
            d = 0;
        }
        
        return (nt,d);
    }
    
    func updateTimeLabel() {
        
        let time = convertSliderToMinute();
        
        self.labelTimeMin.text = String(format: "%02.0f", time.min);
        self.labelTimeSec.text = String(format: "%02.0f", time.sec);
    }

    
    /// MARK: Table View Delegate/Datesource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.numberOfEpisodes();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : EpisodeTableViewCell;
        
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as? EpisodeTableViewCell {
            cell = reuseCell
        } else {
            cell = EpisodeTableViewCell(style: .default, reuseIdentifier: "episodeCell")
        }
        
        let eps = podcasts.episodeAtIndex((indexPath as NSIndexPath).row);
        if eps != nil {
            cell.labelEpisodeName.text = eps!.title;
            cell.labelPodcastName.text = eps!.podcast.title;
            cell.labelDuration.text = UCUtilities.Senconds2String(eps!.duration);
            cell.labelPublishDate.text = UCUtilities.timeAgoSinceDate(eps!.publishDate!);
            cell.labelDownloaded.text = eps!.isDownloaded() ? "Local" : "Stream";
            
            cell.imageCover.image  = UIImage(named: "ImagePlaceholder");
            eps?.podcast.coverImageURL(callback: { (url) in
                cell.imageCover.sd_setImage(with: url);
            })
            
            let diff = UCUtilities.CalculateDifference(from:convertSliderToMinute(), to:eps!.duration);
            cell.labelDifference.text = diff.diff;
            cell.labelDifference.backgroundColor = diff.color;
        }
        
        cell.labelDifference.layer.cornerRadius = 4;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //let eps = podcasts.episodeAtIndex((indexPath as NSIndexPath).row);
        //eps.cancelLoadingImage();
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "seguePlay", sender: podcasts.episodeAtIndex((indexPath as NSIndexPath).row) );
        
    }
    

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "No episode that has this duration";
        let attributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray ]
   
        return NSAttributedString(string: text, attributes: attributes);
    }
}

