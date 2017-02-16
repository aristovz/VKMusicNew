//
//  API.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 29.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class API {
    class Audio {
        class func get(owner_id: Int, requestEnd:@escaping ([AudioTrack]) -> ()) {
            var tracks = [AudioTrack]()
            
            let parameters: Parameters = ["access_token" : Global.token!,
                                          "v" : Global.currentVersion]
            
            Alamofire.request("https://api.vk.com/method/\(Global.currentTypeOfCenter.rawValue)", parameters: parameters).responseJSON { response in
                //print(response.result.value!)
                
                guard response.result.value != nil else {
                    return
                }
                
                let responseJSON: JSON
                
                if Global.currentTypeOfCenter != .PopularController {
                    responseJSON = JSON(response.result.value!)["response"]["items"]
                }
                else {
                    responseJSON = JSON(response.result.value!)["response"]
                }
                
                for song in responseJSON.arrayValue {
                    let cacheTrack = uiRealm.objects(AudioTrack.self).filter("id == \(song["id"].intValue)").first
                    
                    let track = AudioTrack(value: ["id" : song["id"].intValue, "owner_id" : song["owner_id"].intValue, "artist" : song["artist"].stringValue, "title" : song["title"].stringValue, "duration" : song["duration"].intValue, "url" : song["url"].stringValue])
        
                    if let range = track.url.range(of:"(.*).mp3", options: .regularExpression) {
                        track.url = track.url.substring(with: range)
                    }
                    
                    if cacheTrack != nil {
                        track.isDownloaded = true
                        track.filePath = cacheTrack!.filePath
                    }
                    
                    if track.url != "" {
                        tracks.append(track)
                    }
                }
                
                requestEnd(tracks)
            }
        }
    }
}
