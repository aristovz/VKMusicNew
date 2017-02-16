//
//  Global.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 03.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift

class Global {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let appID = "3087106"
    
    static let currentVersion = "5.60"
    
    static var musicPlayer: MusicPlayer?
    
    static var downloadProgress = 0.0
    
    static var currentTypeOfCenter = CenterVC.MyMusicController
    
    static var token: String? {
        get {
            return UserDefaults.standard.value(forKey: "token") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    static var user_id: Int? {
        get {
            return UserDefaults.standard.value(forKey: "user_id") as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_id")
        }
    }
    
    enum CenterVC: String {
        case MyMusicController = "audio.get"
        case SuggestedController = "audio.getRecommendations"
        case PopularController = "audio.getPopular"
        case SavedController = "savedController"
        //case SettingsController = "settingsController"
    }

    
    enum ControllersIdentifiers: String {
        case MyMusicController = "myMusicController"
        case SuggestedController = "suggestedController"
        case PopularController = "popularController"
        case SavedController = "savedController"
        case SettingsController = "settingsController"
        case AuthContoller = "authController"
        case PlayerController = "playerController"
        case NavPlayerController = "navPlayerController"
    }
    
    class func downloadSong(song: AudioTrack) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
        print("startDownload in \(destination)")
        
        Alamofire.download(song.url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination)
            .downloadProgress { progress in
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                
                Global.downloadProgress = progress.fractionCompleted
                
                if progress.fractionCompleted == 1 {
                    Global.downloadProgress = 0
                }
            }
            .response { response -> Void in
                if let error = response.error {
                    print("Failed with error: \(error)")
                    Global.downloadProgress = 0
                    
                } else {
                    try! uiRealm.write {
                        song.filePath = response.response!.suggestedFilename!
                        song.isDownloaded = true
                        uiRealm.add(song)
                    }
                    print("downloaded")
                }
        }
    }

    public class EdgeShadowLayer: CAGradientLayer {
        
        public enum Edge {
            case Top
            case Left
            case Bottom
            case Right
        }
        
        public init(forView view: UIView,
                    edge: Edge = Edge.Top,
                    shadowRadius radius: CGFloat = 100.0,
                    toColor: UIColor = UIColor.clear,
                    fromColor: UIColor = UIColor.black.withAlphaComponent(0.75)) {
            super.init()
            self.colors = [fromColor.cgColor, toColor.cgColor]
            self.shadowRadius = radius
            
            let viewFrame = view.frame
            
            switch edge {
            case .Top:
                startPoint = CGPoint(x: 0.5, y: 0.0)
                endPoint = CGPoint(x: 0.5, y: 1.0)
                self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
            case .Bottom:
                startPoint = CGPoint(x: 0.5, y: 1.0)
                endPoint = CGPoint(x: 0.5, y: 0.0)
                self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
            case .Left:
                startPoint = CGPoint(x: 0.0, y: 0.5)
                endPoint = CGPoint(x: 1.0, y: 0.5)
                self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
            case .Right:
                startPoint = CGPoint(x: 1.0, y: 0.5)
                endPoint = CGPoint(x: 0.0, y: 0.5)
                self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
            }
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class func connectedToNetwork() -> Bool {
        return true
        //        var zeroAddress = sockaddr_in()
//        
//        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//        
//        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
//            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
//        }) else { return false }
//        
//        var flags : SCNetworkReachabilityFlags = []
//        
//        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { return false }
//        
//        let isReachable = flags.contains(.Reachable)
//        let needsConnection = flags.contains(.ConnectionRequired)
//        
//        print("Connection status: \(isReachable && !needsConnection)")
//        
//        return (isReachable && !needsConnection)
    }
}
