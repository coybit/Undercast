//
//  RSSParser.swift
//  Undercast
//
//  Created by coybit on 9/15/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

class UCXMLParser: NSObject, XMLParserDelegate {
    
    var currentPath:[String] = [];
    var parser:Foundation.XMLParser?;
    var selectedPath:String = "";
    var selectedAttribute:String = "";
    var foundValue:String?;
    var callbackFound:((String?)->Void)?;
    var searchingForAttribute: Bool = false;
    var sema1:DispatchSemaphore;
    var sema2:DispatchSemaphore;
    var rssURL:URL;
    var XMLData: Data?;
    var downloadQueue:DispatchQueue;
    
    
    init(contentsOfURL:URL) {
        rssURL = contentsOfURL;
        sema1 = DispatchSemaphore(value: 0);
        sema2 = DispatchSemaphore(value: 0);
        downloadQueue = DispatchQueue(label: "downloadQueue");
    }
    
    func prepare() {
        
        if XMLData==nil {
            
            NSLog("Downloading ... \(rssURL)" );
            
            let sessionConfig = URLSessionConfiguration.default;
            sessionConfig.timeoutIntervalForRequest = 10.0;
            sessionConfig.timeoutIntervalForResource = 20.0;
            
            let task = URLSession.shared.dataTask(with: rssURL, completionHandler: { (data, response, err) in
                
                self.XMLData = data;
                NSLog("Downloaded ... \(self.rssURL)" );
                
                self.sema1.signal();

            }) ;
            
            task.resume();
            sema1.wait();
        }
        
        if self.XMLData == nil {
            NSLog("Faild to download ... \(rssURL)");
            return;
        }
        else {
            NSLog("Processing ... \(rssURL)");
        }
        
        self.parser = Foundation.XMLParser(data: self.XMLData!);
        self.parser!.shouldResolveExternalEntities = false;
        self.parser!.delegate = self;
        let ret = self.parser!.parse();
        
        if ret == false {
            sema2.signal();
        }
    }
    
    func valueForAttribute(_ path: String, attribute: String) -> String? {
    
        searchingForAttribute = true;
        selectedPath = path;
        selectedAttribute = attribute;
        
        //downloadQueue.async {
            self.prepare();
        //};
        
        NSLog("Start Processing ... \(rssURL)");
        sema2.wait();
        NSLog("Finish Processing ... \(rssURL)");
        
        return foundValue;
    
    }
    
    func valueForPath(_ path: String ) -> String? {
        
        searchingForAttribute = false;
        selectedPath = path;
        
        //downloadQueue.async {
            self.prepare();
        //};
        
        NSLog("Start Processing ... \(rssURL)");
        sema2.wait();
        NSLog("Finish Processing ... \(rssURL)");
        
        return foundValue;
    }
    
    func comparePath() -> Bool {
        
        var i = 0;
        let components = selectedPath.components(separatedBy: "/");
        
        if components.count != self.currentPath.count {
            return false;
        }
        
        for component in components {
            
            if component != self.currentPath[i] {
                return false;
            }
            i+=1;
            
        }
        
        return true;
    }
    
    // MARK: - NSXML Parse delegate function
    
    // start parsing document
    func parserDidStartDocument(_ parser: UCXMLParser) {
        // start parsing
    }
    
    // element start detected
    func parser(_ parser: UCXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentPath.append(elementName);
        
        if searchingForAttribute {
            if comparePath() {
                
                foundValue = attributeDict[selectedAttribute];
                sema2.signal();
                
            }
        }
    }
    
    // characters received for some element
    
    func parser(_ parser: UCXMLParser, foundCharacters string: String) {
        
        if !searchingForAttribute {
            if comparePath() {
                
                foundValue = string;
                sema2.signal();
    
            }
        }
    }
    
    // element end detected
    func parser(_ parser: UCXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        currentPath.removeLast();
    }
    
    // end parsing document
    func parserDidEndDocument(_ parser: UCXMLParser) {
        sema2.signal();
    }
    
    // if any error detected while parsing.
    func parser(_ parser: UCXMLParser, parseErrorOccurred parseError: Error) {
        
        NSLog("Error");
        sema2.signal();
        
    }
}
