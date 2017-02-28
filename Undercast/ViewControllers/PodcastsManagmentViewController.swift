//
//  PodcastsManagmentViewController.swift
//  Undercast
//
//  Created by coybit on 9/14/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class PodcastsManagmentViewController: UIViewController, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {

    @IBOutlet weak var tableResults: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    let appID = "2e498f287f7d1dd9078d8b969120a386";
    let baseURL = "http://api.digitalpodcast.com/v2r";
    var parser:Foundation.XMLParser = Foundation.XMLParser();
    var results:[Podcast] = [];
    var XMLPath:[String] = [];
    var queue:OperationQueue = OperationQueue();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        queue.qualityOfService = .userInitiated;
        queue.maxConcurrentOperationCount = 5;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func searchBtnDidTouch(_ sender: AnyObject) {
        search( txtSearch.text! as NSString );
        results = [];
        self.tableResults.reloadData();
        txtSearch.resignFirstResponder()
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
        
        let searchKeywords = term.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed);
        let apiURL = "\(baseURL)/search/?appid=\(appID)&format=rssopml&keywords=\(searchKeywords!)"
        
        let url = URL(string: apiURL);
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, res, err) in
            
            // ToDo: check for nil
            
            self.parser = Foundation.XMLParser(data: data!);
            self.parser.shouldResolveExternalEntities = false;
            self.parser.delegate = self;
            self.parser.parse();
            
        }) ;
        task.resume();
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UILabel();
        header.text = section==0 ? "Results" : "Subscribed"
        header.backgroundColor = UIColor.lightGray;
        return header;
        
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
            cell!.imgCover.image = nil;
            
            queue.addOperation {
                
                self.results[(indexPath as NSIndexPath).row].loadCoverImageAsync();
                
                OperationQueue.main.addOperation({
                    
                    if let cell = self.tableResults.cellForRow(at: indexPath) {
                        
                        (cell as? PodcastTableViewCell)!.imgCover.image = self.results[(indexPath as NSIndexPath).row].coverImage;
                    }
                    
                });
                
                
            };
        }
        else {
            
            let idx = indexPath.row;
            let podcast = Podcasts.shared.podcastAtIndex(index: idx);
            
            cell!.labelTitle.text = podcast.title as String;
            cell!.labelDescription.text = podcast.text as String;
            
            if podcast.coverImage != nil {
                cell!.imgCover.image = podcast.coverImage;
            }
            else {
                queue.addOperation {
                    
                    podcast.loadCoverImageAsync();
                    
                    OperationQueue.main.addOperation({
                        
                        if let cell = self.tableResults.cellForRow(at: indexPath) {
                            
                            (cell as? PodcastTableViewCell)!.imgCover.image = podcast.coverImage;
                        }
                        
                    });
                    
                    
                };
            }
            
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
    
    // MARK: - NSXML Parse delegate function
    
    // start parsing document
    func parserDidStartDocument(_ parser: XMLParser) {
        // start parsing
    }
    
    // element start detected
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "outline" {
            let podcast = Podcast();
            podcast.title = attributeDict["text"]!;
            podcast.link = attributeDict["xmlUrl"]!;
            podcast.text = attributeDict["description"]!;
            results.append(podcast);
        }
    }
    
    // characters received for some element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
    
    // element end detected
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }
    
    // end parsing document
    func parserDidEndDocument(_ parser: XMLParser) {
        
        DispatchQueue.main.async { 
            self.tableResults.reloadData();
        };
    }
    
    // if any error detected while parsing.
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        NSLog("Error");
        
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "No Result";
        let attributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.darkGray ]
        
        return NSAttributedString(string: text, attributes: attributes);
    }
}

    
