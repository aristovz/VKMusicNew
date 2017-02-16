//
//  Extensions.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 29.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
import AVFoundation

extension UIColor {
    convenience init(hexString: String) {
        let hexString: NSString = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    class func backgroundColor() -> UIColor {
        return UIColor(hexString: "192029")
    }
    
    class func backgroundLightColor() -> UIColor {
        return UIColor(hexString: "4E525D")
    }
    
    class func defaultBlueColor() -> UIColor {
        return UIColor(hexString: "4EDDE8")
    }
    
    class func backGroundDarkColor() -> UIColor {
        return UIColor(hexString: "282A32")
    }
}

extension UIApplication {
    func _handleNonLaunchSpecificActions(arg1: AnyObject, forScene arg2: AnyObject, withTransitionContext arg3: AnyObject, completion completionHandler: () -> Void) {
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
//extension VKAudio {
//    func getArtworkImage() -> UIImage {
//        var currentImage = Global.noArtworkImage
//        
//        let asset = AVURLAsset(URL: NSURL(string: self.url)!)
//        asset.loadValuesAsynchronouslyForKeys(["metadata"], completionHandler: {
//            for item in asset.metadata {
//                if item.commonKey == nil{
//                    continue
//                }
//                
//                if let key = item.commonKey, let value = item.value {
//                    if key == "artwork" {
//                        if let audioImage = UIImage(data: value as! NSData) {
//                            //println(audioImage.description)
//                            currentImage = audioImage
//                        }
//                    }
//                }
//            }
//        })
//        
//        return currentImage!
//    }
//}

//extension Double {
//    /// Rounds the double to decimal places value
//    func roundToPlaces(places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return round(self * divisor) / divisor
//    }
//}
