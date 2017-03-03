//
//  DownloadsTableViewController.swift
//  Undercast
//
//  Created by coybit on 9/20/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import ChameleonFramework

class DownloadsTableViewController: UITableViewController, DZNEmptyDataSetSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        self.navigationController?.hidesNavigationBarHairline = true;
        self.navigationController?.navigationBar.barTintColor = UIColor.flatOrange();
        
        NotificationCenter.default.addObserver(forName: UCNotificationReplicationStatusDidChange, object: nil, queue: OperationQueue.main) { (notif) in
            
            self.tableView.reloadData();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UCDownloader.sharedInstance.downoadList().count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DownloadTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellDownload", for: indexPath) as! DownloadTableViewCell;

        // Configure the cell...
        let eps = UCDownloader.sharedInstance.itemAtIndex((indexPath as NSIndexPath).row);
        
        cell.labelTitle.text = eps?.title;
        cell.labelSubtitle.text = eps?.downloadingStatus.rawValue;
        cell.progress = (eps?.downloadProgress)!;
        cell.downloadID = eps?.downloadID;

        return cell
    }
    

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "No Download";
        let attributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray ]
        
        return NSAttributedString(string: text, attributes: attributes);
    }
    

}
