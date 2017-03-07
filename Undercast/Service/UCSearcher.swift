//
//  UCSearcher.swift
//  Undercast
//
//  Created by Malij on 3/3/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import UIKit

public class UCSearcher: NSObject, XMLParserDelegate {
    
    let appID = "2e498f287f7d1dd9078d8b969120a386";
    let baseURL = "http://api.digitalpodcast.com/v2r";
    var parser:Foundation.XMLParser = Foundation.XMLParser();
    var results:[Podcast] = [];
    var XMLPath:[String] = [];
    var queue:OperationQueue = OperationQueue();
    var callback:(([Podcast])->Void)!;
    
    
    
    public func Seach(term:String, callback:@escaping ([Podcast])->Void ) {
        
        self.callback = callback;
        
        queue.qualityOfService = .userInitiated;
        queue.maxConcurrentOperationCount = 5;
        queue.addOperation {
            self.requestForSearch(term: term);
        }

        
    }

    func requestForSearch(term:String) {
        
        let searchKeywords = term.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed);
        let apiURL = "\(baseURL)/search/?appid=\(appID)&format=rssopml&keywords=\(searchKeywords!)"
        
        let url = URL(string: apiURL);
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, res, err) in
            
            if data == nil {
                // ToDo: Show an alert
                return;
            }
            
            self.parser = Foundation.XMLParser(data: data!);
            self.parser.shouldResolveExternalEntities = false;
            self.parser.delegate = self;
            self.parser.parse();
            
        }) ;
        task.resume();
        
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
            self.callback(self.results);
        };
    }
    
    // if any error detected while parsing.
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        NSLog("Error");
        
    }
    
}

