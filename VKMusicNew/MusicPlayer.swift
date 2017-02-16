//
//  MusicPlayer.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 29.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import Alamofire
import RealmSwift

class MusicPlayer: NSObject {
    
    var player: AVPlayer?
    var tracks = [AudioTrack]()// VKAudios()
    var playerItem: AVPlayerItem?
    //var player: AVQueuePlayer?
    
    var repeatSong = false
    var shuffleSongs = false
    
    var _currentTrackIndex = 0
    var _fromCache = false
    
    init(tracks: [AudioTrack], fromCache: Bool = false) {
        self.tracks = tracks
        _fromCache = fromCache
        super.init()

        queueTrack()
    }
    
    private func queueTrack() {
        if (player != nil) { player = nil }
        
        if tracks.count != 0 {
            //Global.setPlayingIndex()
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : currentTrack.artist,  MPMediaItemPropertyTitle : currentTrack.title]
            
            if _fromCache || currentTrack.isDownloaded {
                let asset = AVAsset(url: currentTrack.getFullPath())
                playerItem = AVPlayerItem(asset: asset)
            }
            else {
                playerItem = AVPlayerItem(url: URL(string: currentTrack.url)!)
            }
            
            player = AVPlayer(playerItem: playerItem!)
        }
    }
    
    func play() {
        if player?.rate == 0 { player?.play() }
    }
    
    func stop() {
        if player?.rate == 1 {
            player?.pause()
            player?.seek(to: kCMTimeZero)
        }
    }
    
    func pause() {
        if player?.rate == 1 {
            player?.pause()
        }
    }
    
    func playPause() {
        if player?.rate == 1 {
            pause()
        }
        else if player?.rate == 0 {
            play()
        }
    }
    
    func nextSong(songFinishedPlaying: Bool = false) {
        var playerWasPlaying = false
        
        if player?.rate == 1 {
            stop()
            playerWasPlaying = true
        }
        
        if repeatSong && songFinishedPlaying {
            setNewTime(progress: 0)
            player?.play()
            return
        }
        else if shuffleSongs {
            _currentTrackIndex = Int(arc4random_uniform(UInt32(tracks.count)))
        }
        else {
            _currentTrackIndex = nextIndex
        }
        
        queueTrack()
        if playerWasPlaying || songFinishedPlaying {
            player?.play()
        }
    }
    
    func previousSong() {
        var playerWasPlaying = false
        
        if player?.rate == 1 {
            stop()
            playerWasPlaying = true
        }
        
        if shuffleSongs {
            _currentTrackIndex = Int(arc4random_uniform(UInt32(tracks.count)))
        }
        else {
            _currentTrackIndex = previousIndex
        }
        
        queueTrack()
        if playerWasPlaying { player?.play() }
    }
    
    func setVolume(volume: Float) {
        player?.volume = volume
    }
    
    func setNewTime(progress: Float) {
        var theCurrentTime: Float = 0.0
        
        //if let duration = currentTrack.duration {
            theCurrentTime = Float(currentTrack.duration) * progress
        //}
        
        let timeScale = player?.currentItem?.asset.duration.timescale
        player?.seek(to: CMTime(seconds: Double(theCurrentTime), preferredTimescale: timeScale!))
    }
    
    func getCurrentTimeAsString(progress: Float) -> String {
        var seconds = 0
        var minutes = 0
        
        if player != nil {
            let time = Float(currentTrack.duration) * progress
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    func getLeftTimeAsString(progress: Float) -> String {
        var seconds = 0
        var minutes = 0
        
        if player != nil {
            let currentTime = Float(currentTrack.duration) * progress
            let duration = currentTrack.duration
            
            let time = currentTime - Float(duration)
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        
        return String(format: "%0.2d:%0.2d",minutes,-seconds)
    }
    
    func getProgress() -> Float {
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        
        if let currentTime = player?.currentTime().seconds {//, let duration = currentTrack.duration {
            theCurrentTime = currentTime
            theCurrentDuration = Double(currentTrack.duration)
        }
        
        return Float(theCurrentTime / theCurrentDuration)
    }
    
    var currentTrack: AudioTrack {
        get { return tracks[_currentTrackIndex] }
    }
    
    var currentTrackIndex: Int {
        get { return _currentTrackIndex }
        set {
            _currentTrackIndex = newValue
            queueTrack()
        }
    }
    
    var nextIndex: Int {
        get {
            var index = _currentTrackIndex + 1
            if index == tracks.count {
                index = 0
            }
            
            return index
        }
    }
    
    var previousIndex: Int {
        get {
            var index = _currentTrackIndex - 1
            if _currentTrackIndex == 0 {
                index = tracks.count - 1
            }
            
            return index
        }
    }
}
