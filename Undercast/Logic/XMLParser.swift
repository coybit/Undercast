//
//  RSSParser.swift
//  Undercast
//
//  Created by coybit on 9/15/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

class XMLParser: NSObject, XMLParserDelegate {
    
    var currentPath:[String] = [];
    var parser:Foundation.XMLParser?;
    var selectedPath:String = "";
    var selectedAttribute:String = "";
    var foundValue:String?;
    var callbackFound:((String?)->Void)?;
    var searchingForAttribute: Bool = false;
    var sema:DispatchSemaphore;
    var rssURL:URL;
    var XMLData: Data?;
    
    
    init(contentsOfURL:URL) {
        rssURL = contentsOfURL;
        sema = DispatchSemaphore(value: 0);
    }
    
    func prepare() {
        
        if XMLData==nil {
            
            NSLog("Downloading ... \(rssURL)" );
            
            let sessionConfig = URLSessionConfiguration.default;
            sessionConfig.timeoutIntervalForRequest = 10.0;
            sessionConfig.timeoutIntervalForResource = 20.0;
            
            let task = URLSession.shared.dataTask(with: rssURL, completionHandler: { (data, response, err) in
                
                self.XMLData = data;
                self.sema.signal();

            }) ;
            
            task.resume();
            sema.wait(timeout: DispatchTime.distantFuture);
        }
        
        if self.XMLData == nil {
            NSLog("Faild to download ... \(rssURL)");
            return;
        }
        
        self.parser = Foundation.XMLParser(data: self.XMLData!);
        self.parser!.shouldResolveExternalEntities = false;
        self.parser!.delegate = self;
        self.parser!.parse();
    }
    
    func valueForAttribute(_ path: String, attribute: String) -> String? {
    
        searchingForAttribute = true;
        selectedPath = path;
        selectedAttribute = attribute;
        
        prepare();
        
        NSLog("Start Processing ... \(rssURL)");
        sema.wait(timeout: DispatchTime.distantFuture);
        NSLog("Finish Processing ... \(rssURL)");
        
        return foundValue;
    
    }
    
    func valueForPath(_ path: String ) -> String? {
        
        searchingForAttribute = false;
        selectedPath = path;
        
        prepare();
        
        NSLog("Start Processing ... \(rssURL)");
        sema.wait(timeout: DispatchTime.distantFuture);
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
    private func parserDidStartDocument(_ parser: XMLParser) {
        // start parsing
    }
    
    // element start detected
    private func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentPath.append(elementName);
        
        if searchingForAttribute {
            if comparePath() {
                
                foundValue = attributeDict[selectedAttribute];
                sema.signal();
                
            }
        }
    }
    
    // characters received for some element
    
    private func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if !searchingForAttribute {
            if comparePath() {
                
                foundValue = string;
                sema.signal();
    
            }
        }
    }
    
    // element end detected
    private func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        currentPath.removeLast();
    }
    
    // end parsing document
    private func parserDidEndDocument(_ parser: XMLParser) {
        sema.signal();
    }
    
    // if any error detected while parsing.
    private func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        NSLog("Error");
        
    }
}
