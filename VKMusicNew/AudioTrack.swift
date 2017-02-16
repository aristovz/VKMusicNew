//
//  AudioTrack.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 31.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import RealmSwift

class AudioTrack: Object {
    dynamic var id: Int = 0
    dynamic var owner_id: Int = 0
    dynamic var artist: String = ""
    dynamic var title: String = ""
    dynamic var duration: Int = 0
    dynamic var url: String = ""
    
    dynamic var filePath: String? = nil
    dynamic var isDownloaded = false
    //dynamic var artwork: UIImage? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getFullPath() -> URL {
        guard self.filePath != nil else {
            return URL(string: self.filePath!)!
        }
        
        let fileManager = FileManager.default
        let wayToFile = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
        if let documentPath: NSURL = wayToFile.first as NSURL? {
            return documentPath.appendingPathComponent(self.filePath!)!
        }
        
        return URL(string: self.filePath!)!
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
