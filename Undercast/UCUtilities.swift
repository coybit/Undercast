//
//  Utilities.swift
//  
//
//  Created by Malij on 2/28/17.
//
//

import UIKit

class UCUtilities: NSObject {

    static func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    
    static func convertDateToReadableFormat(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MMM-dd"
        return dateFormatter.string(from: date)
        
    }
    
    static func timeAgoSinceDate(_ date:Date) -> String {
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
    
    static func CalculateDifference(from orgTime:(min:Float,sec:Float) , to EpisodeDuration: Int) -> (diff: String, color: UIColor) {
        
        let green = UIColor.init(colorLiteralRed: 70.0/255, green: 197.0/255, blue: 79.0/255, alpha: 1.0);
        let red = UIColor.init(colorLiteralRed: 206.0/255, green: 63.0/255, blue: 63.0/255, alpha: 1.0)
        
        let time = orgTime;
        let sec = Int(time.min * 60 + time.sec);
        var diff = EpisodeDuration - sec;
        let unit = abs(diff) > 60 ? "min" : "sec";
        let color = diff < 0 ? red : green;
        diff = abs(diff) > 60 ? diff/60 : diff;
        
        return ("\(Int(diff)) \(unit)",color);
    }
    
    static func Senconds2String(_ seconds: Int) -> String {
        
        let min:Float = Float(seconds / 60);
        let sec:Float = Float(seconds) - min*60.0;
        return String(format: "%02.0f:%02.0f", min, sec);
        
    }
    
    
}
