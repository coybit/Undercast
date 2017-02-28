//
//  DownloadsTableViewController.swift
//  Undercast
//
//  Created by coybit on 9/20/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class DownloadsTableViewController: UITableViewController, DZNEmptyDataSetSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadListDidChange), name: NSNotification.Name(rawValue: NCDownloadListDidChange), object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func DownloadListDidChange(_ userInfo:AnyObject?) {
        
        OperationQueue.main.addOperation { 
          
            self.tableView.reloadData();
            
        };
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Downloader.sharedInstance.downoadList().count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DownloadTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellDownload", for: indexPath) as! DownloadTableViewCell;

        // Configure the cell...
        let eps = Downloader.sharedInstance.itemAtIndex((indexPath as NSIndexPath).row);
        
        cell.labelTitle.text = eps?.title;
        cell.labelSubtitle.text = eps?.downloadingStatus.rawValue;
        cell.progressState.progress = (eps?.downloadProgress)!;
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
