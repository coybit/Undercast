//
//  PodcastDetailViewController.swift
//  Undercast
//
//  Created by coybit on 9/15/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import SDWebImage
import MarkedView

class PodcastDetailViewController: UnderViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var markdownView: UIMarkedView!
    @IBOutlet weak var tableEpisodes: UITableView!
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    
    var podcast:Podcast?;
    var podcasts:Podcasts = Podcasts();
    var episodes:[Episode] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.labelTitle.text = podcast!.title;
        self.imgCover.sd_setImage(with: podcast?.coverImgURL);
        self.markdownView.textToMark(podcast!.text);
        
        loadDynamicLabels();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func subscribeDidTouch(_ sender: AnyObject) {

        if podcast!.isSubscribed() {
            podcast!.unsubscribe();
        }
        else {
            podcast!.subscribe();
        }
        
        loadDynamicLabels();
    }
    
    func loadDynamicLabels() {
        
        if podcast!.isSubscribed() {
            self.btnSubscribe.setTitle("Unsubscribe", for: UIControlState() );
        }
        else {
            self.btnSubscribe.setTitle("Subscribe", for: UIControlState() );
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (podcast?.episodes.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell");
        
        (cell?.viewWithTag(100) as! UILabel).text = podcast?.episodes[ indexPath.row ].title;
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "seguePlay", sender: podcast?.episodes[indexPath.row] );
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "seguePlay" {
            
            if sender != nil {
                let vc = segue.destination as! PlayerViewController;
                vc.CurrentEpisode = sender as! Episode;
            }
        }
        
    }
}
