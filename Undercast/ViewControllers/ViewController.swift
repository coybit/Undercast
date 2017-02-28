//
//  ViewController.swift
//  Undercast
//
//  Created by coybit on 9/9/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource  {

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
        //queue.maxConcurrentOperationCount = 5;
        
        self.updateTimeLabel();
        
        podcasts.loadSubscribedPodcast();
        
        // A little trick for removing the cell separators
        tableEpisodes.tableFooterView = UIView();

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
            cell.labelDuration.text = self.Senconds2String(eps!.duration);
            cell.labelPublishDate.text = timeAgoSinceDate(eps!.publishDate!);
            cell.labelDownloaded.text = eps!.isDownloaded() ? "Local" : "Stream";
            
            if eps!.podcast.coverImage != nil {
                cell.imageCover.image = eps!.podcast.coverImage;
            }
            else {
                cell.imageCover.image = nil;
                queue.addOperation({
                    
                    self.semaphore.wait();
                    
                    eps!.podcast.loadCoverImageAsync();
                    
                    self.semaphore.signal();
                    
                    OperationQueue.main.addOperation({
                        
                        if let cell = tableView.cellForRow(at: indexPath) {
                            
                            let ecell = cell as! EpisodeTableViewCell;
                            ecell.imageCover.image = eps!.podcast.coverImage;
                        }
                        
                    });
                    
                })
            }
            
            
            
            let diff = CalculateDifference(eps!.duration);
            cell.labelDifference.text = diff.diff;
            cell.labelDifference.backgroundColor = diff.color;
        }
        
        cell.labelDifference.layer.cornerRadius = 4;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let eps = podcasts.episodeAtIndex((indexPath as NSIndexPath).row);
        //eps.cancelLoadingImage();
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "seguePlay", sender: podcasts.episodeAtIndex((indexPath as NSIndexPath).row) );
        
    }
    
    func convertDateToReadableFormat(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MMM-dd"
        return dateFormatter.string(from: date)
        
    }
    
    func timeAgoSinceDate(_ date:Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([.minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest, options: .wrapComponents)

        if (components.year! >= 1){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MMM"
            return dateFormatter.string(from: date)
            
        }
        else if(components.weekOfYear! >= 1) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd"
            return dateFormatter.string(from: date)
            
        }
        else if (components.day! >= 2) {
            return "\(components.day) days ago"
        } else if (components.day! >= 1){
            return "Yesterday"
            
        } else if (components.hour! >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour! >= 1){
            return "An hour ago"
        } else if (components.minute! >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute! >= 1){
            return "A minute ago"
        } else if (components.second! >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }

    }
    
    func CalculateDifference(_ EpisodeDuration: Int) -> (diff: String, color: UIColor) {
        
        let green = UIColor.init(colorLiteralRed: 70.0/255, green: 197.0/255, blue: 79.0/255, alpha: 1.0);
        let red = UIColor.init(colorLiteralRed: 206.0/255, green: 63.0/255, blue: 63.0/255, alpha: 1.0)
        
        let time = convertSliderToMinute();
        let sec = Int(time.min * 60 + time.sec);
        var diff = EpisodeDuration - sec;
        let unit = abs(diff) > 60 ? "min" : "sec";
        let color = diff < 0 ? red : green;
        diff = abs(diff) > 60 ? diff/60 : diff;
        
        return ("\(Int(diff)) \(unit)",color);
    }
    
    func Senconds2String(_ seconds: Int) -> String {
        
        let min:Float = Float(seconds / 60);
        let sec:Float = Float(seconds) - min*60.0;
        return String(format: "%02.0f:%02.0f", min, sec);
        
    }
    
    
    @IBAction func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        
        let delta = sender.translation(in: self.view);
        let expandHeight:CGFloat = 250;
        let normalHeight:CGFloat = 150;
        let minDelta:CGFloat = 20;
        let maxDelta:CGFloat = expandHeight - normalHeight;
        
        //print(delta);
        
        if sender.state == .began {
            //print("Start");
            
        }
        else if sender.state == .changed {
            //print("Change");
            
            if filterViewIsExpanded {
                
                if delta.y < 0 && delta.y > -maxDelta {
                    self.conFilterViewHeight.constant = expandHeight + delta.y;
                    self.view.layoutIfNeeded();
                }
                
            }
            else {
                
                if delta.y > 0 && delta.y < maxDelta {
                    self.conFilterViewHeight.constant = normalHeight + delta.y;
                    self.view.layoutIfNeeded();
                }
                
            }
            
        }
        else if sender.state == .cancelled || sender.state == .ended {
            
            var newHeight:CGFloat = 0.0;
            
            if filterViewIsExpanded {
                
                if delta.y < -minDelta {
                    newHeight = normalHeight;
                    filterViewIsExpanded = false;
                }
                else {
                    newHeight = expandHeight;
                    filterViewIsExpanded = true;
                }
                
            }
            else {
                
                if delta.y < minDelta {
                    newHeight = normalHeight;
                    filterViewIsExpanded = false;
                }
                else {
                   newHeight = expandHeight;
                   filterViewIsExpanded = true;
                }
                
            }
            
            UIView.animate(withDuration: 0.1, animations: { 
                
                self.conFilterViewHeight.constant = newHeight;
                self.view.layoutIfNeeded();
                
            });
            
            //print("End");
        }
        
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "No episode that has this duration";
        let attributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray ]
   
        return NSAttributedString(string: text, attributes: attributes);
    }
}

