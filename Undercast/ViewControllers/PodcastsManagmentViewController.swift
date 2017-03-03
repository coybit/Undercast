//
//  PodcastsManagmentViewController.swift
//  Undercast
//
//  Created by coybit on 9/14/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class PodcastsManagmentViewController: UnderViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {

    @IBOutlet weak var tableResults: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    var results:[Podcast] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func searchDidTap(_ sender: Any) {

        results = [];
        self.tableResults.reloadData();
        txtSearch.resignFirstResponder()
        
        txtSearch.endEditing(true);
        
        let searcher = UCSearcher();
        searcher.Seach(term: txtSearch.text!) { (results) in
            
            self.results = results;
            self.tableResults.reloadData();
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func search(_ term: NSString) {
        

    }
    
    /// MARK: Tableview delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return results.count;
        }
        else {
            return Podcasts.shared.numberOfSubscribedPodcasts();
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if section == 0 && section == 0 {
            return 0;
        }
        else {
            return 21;
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect.zero);
        headerView.backgroundColor = UIColor.flatGray();
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 0, height: 0));
        headerLabel.text = section==0 ? "Results" : "Subscribed"
        headerLabel.sizeToFit();
        
        headerView.addSubview(headerLabel);
        
        return headerView;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:PodcastTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellPodcast") as? PodcastTableViewCell;
        
        if cell == nil  {
            cell = PodcastTableViewCell();
        }
        
        if (indexPath as NSIndexPath).section == 0 {
            // Prepare cell
            cell!.labelTitle.text = results[(indexPath as NSIndexPath).row].title as String;
            cell!.labelDescription.text = results[(indexPath as NSIndexPath).row].text as String;
            cell!.imgCover.sd_setImage(with: results[(indexPath as NSIndexPath).row].coverImgURL);
        }
        else {
            
            let idx = indexPath.row;
            let podcast = Podcasts.shared.podcastAtIndex(index: idx);
            
            cell!.labelTitle.text = podcast.title as String;
            cell!.labelDescription.text = podcast.text as String;
            cell!.imgCover.sd_setImage(with: podcast.coverImgURL);
            
            cell?.labelDescription.sizeToFit();
        }
        
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "segueDetails", sender: indexPath);
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = (sender as! IndexPath);
        let dst = (segue.destination as! PodcastDetailViewController);
        
        if segue.destination is PodcastDetailViewController {
            
            if (indexPath as NSIndexPath).section == 0 {
                dst.podcast = results[(indexPath as NSIndexPath).row];
            }
            else {
                dst.podcast = Podcasts.shared.podcastAtIndex(index:indexPath.row);
            }
        }
        
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "No Result";
        let attributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray ]
        
        return NSAttributedString(string: text, attributes: attributes);
    }
}

    
