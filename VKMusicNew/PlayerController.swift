//
//  PlayerController.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 29.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import DrawerController
import AVFoundation
import MediaPlayer

class PlayerController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var loopButtonOutlet: UIButton!
    @IBOutlet weak var shuffleButtonOutlet: UIButton!
    
    
    
    var timer: Timer?
    let masterVolumeSlider: MPVolumeView = MPVolumeView()
    
    var loadedArtwork = false
    
    var progressViewLayer = CAGradientLayer()
    
    //let didDownloadView = downloadView()
    //let downloadProcessView = progressView(frame: CGRect(x: 0, y: 4, width: 25, height: 25))
    
    var tapParent: UITapGestureRecognizer!
    var changeCurrentTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressViewLayer.frame = CGRect(x: 0, y: 0, width: 100, height: self.posterImage.frame.height)
        progressViewLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.2).cgColor]
        
        //currentTimeSlider.transform = CGAffineTransform(scaleX: 1, y: 3)
        currentTimeSlider.setThumbImage(#imageLiteral(resourceName: "thumbIcon"), for: .normal)
        
        posterImage.layer.sublayers?.removeAll()
        
        let topShadow = Global.EdgeShadowLayer(forView: posterImage, edge: .Top)
        posterImage.layer.addSublayer(topShadow)
        
        let bottomShadow = Global.EdgeShadowLayer(forView: posterImage, edge: .Bottom)
        posterImage.layer.addSublayer(bottomShadow)
        
        let leftShadow = Global.EdgeShadowLayer(forView: posterImage, edge: .Left)
        posterImage.layer.addSublayer(leftShadow)
        
        let rightShadow = Global.EdgeShadowLayer(forView: posterImage, edge: .Right)
        posterImage.layer.addSublayer(rightShadow)
        
        posterImage.layer.addSublayer(progressViewLayer)
        
        //tapParent = UITapGestureRecognizer(target: self, action: "downloadButton:")
        //progreesDownView.addGestureRecognizer(tapParent)
        
        volumeSlider.setThumbImage(#imageLiteral(resourceName: "volume"), for: .normal)
        
        fillInfoAboutSong()
        
        Global.musicPlayer?.play()
        startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Global.appDelegate.drawerController != nil {
            Global.appDelegate.drawerController.openDrawerGestureModeMask = .custom
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Global.appDelegate.drawerController.openDrawerGestureModeMask = .all
        //didDownloadView.removeFromSuperview()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if (event!.type == UIEventType.remoteControl)
        {
            switch (event!.subtype)
            {
            case UIEventSubtype.remoteControlPlay:
                Global.musicPlayer?.play()
                break
                
            case  UIEventSubtype.remoteControlPause:
                // pause the video
                Global.musicPlayer?.pause()
                break
                
            case  UIEventSubtype.remoteControlNextTrack:
                // to change the video
                Global.musicPlayer?.nextSong()
                break
                
            case  UIEventSubtype.remoteControlPreviousTrack:
                // to play the privious video
                Global.musicPlayer?.previousSong()
                break
                
            default:
                break
            }
        }
    }
    
    func fillInfoAboutSong() {
        posterImage.image = #imageLiteral(resourceName: "CoverArt")
        //  if Global.musicPlayer!.currentTrack.artwork == nil {
            loadPoster()
//        }
//        else {
//            posterImage.image = Global.musicPlayer!.currentTrack.artwork
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: Global.musicPlayer?.player?.currentItem)
        
        setSupportedIcons()
        updateViews()
    }
    
    func updateViews() {
        trackName.text = Global.musicPlayer!.currentTrack.title
        artistLabel.text = Global.musicPlayer!.currentTrack.artist
        progressLabel.text = Global.musicPlayer!.currentTrack.isDownloaded ? "100 %" : "\(Int(Global.downloadProgress * 100)) %"
        downloadButtonOutlet.setImage(Global.musicPlayer!.currentTrack.isDownloaded ? #imageLiteral(resourceName: "heartSelected") : #imageLiteral(resourceName: "heartNoSelected"), for: .normal)
        
        if !changeCurrentTime {
            currentTimeSlider.value = Global.musicPlayer!.getProgress()
            progressViewLayer.frame = CGRect(x: 0, y: 0, width: self.posterImage.frame.width * CGFloat(currentTimeSlider.value), height: self.posterImage.frame.height)
        }
        
        currentTimeLabel.text = Global.musicPlayer?.getCurrentTimeAsString(progress: currentTimeSlider.value)
        timeLeftLabel.text = Global.musicPlayer?.getLeftTimeAsString(progress: currentTimeSlider.value)
        
        if Global.musicPlayer?.player?.rate == 1 {
            playButtonOutlet.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        else if Global.musicPlayer?.player?.rate == 0 {
            playButtonOutlet.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        
        if let view = masterVolumeSlider.subviews.first as? UISlider {
            volumeSlider.value = view.value
        }
    }
    
    func loadPoster() {
        //Global.musicPlayer!.currentTrack.artwork = #imageLiteral(resourceName: "CoverArt")
        let asset = AVURLAsset(url: URL(string: (Global.musicPlayer?.currentTrack.url)!)! as URL)
        asset.loadValuesAsynchronously(forKeys: ["metadata"], completionHandler: {
            for item in asset.metadata {
                if item.commonKey == nil{
                    continue
                }
                
                if let key = item.commonKey, let value = item.value {
                    if key == "artwork" {
                        if let audioImage = UIImage(data: value as! Data) {
                            DispatchQueue.main.async {
                                self.posterImage.image = audioImage
                                //Global.musicPlayer?.currentTrack.artwork = audioImage
                            }
                        }
                    }
                }
            }
        })
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateViewsWithTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func updateViewsWithTimer(_ theTimer: Timer){
        updateViews()
    }
    
    func setSupportedIcons() {
        if Global.musicPlayer!.shuffleSongs { shuffleButtonOutlet.setImage(#imageLiteral(resourceName: "shuffleSelected"), for: .normal) }
        else { shuffleButtonOutlet.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal) }
        
        if Global.musicPlayer!.repeatSong { loopButtonOutlet.setImage(#imageLiteral(resourceName: "repeatSelected"), for: .normal) }
        else { loopButtonOutlet.setImage(#imageLiteral(resourceName: "repeat"), for: .normal) }
    }
    
    func downloadSong() {
        if Global.musicPlayer!._fromCache { return }
        Global.downloadSong(song: Global.musicPlayer!.currentTrack)
    }
    
    func finishedPlaying(_ myNotification:NSNotification) {
        timer?.invalidate()
        Global.musicPlayer?.nextSong(songFinishedPlaying: true)
        
        fillInfoAboutSong()
        startTimer()
    }
    
    @IBAction func playButtonAction(sender: UIButton) {
        Global.musicPlayer?.playPause()
        timer?.invalidate()
        startTimer()
    }
    
    @IBAction func nextSongButton(sender: UIButton) {
        
        Global.musicPlayer?.nextSong()
        timer?.invalidate()
        
        startTimer()
        fillInfoAboutSong()
    }
    
    @IBAction func previousSongButton(sender: UIButton) {
        Global.musicPlayer?.previousSong()
        timer?.invalidate()
        startTimer()
        fillInfoAboutSong()
    }
    
    @IBAction func shuffleButton(sender: UIButton) {
        if Global.musicPlayer!.shuffleSongs { Global.musicPlayer?.shuffleSongs = false }
        else { Global.musicPlayer?.shuffleSongs = true }
        
        setSupportedIcons()
    }
    
    @IBAction func repeatButton(sender: UIButton) {
        if Global.musicPlayer!.repeatSong { Global.musicPlayer?.repeatSong = false }
        else { Global.musicPlayer?.repeatSong = true }
        
        setSupportedIcons()
    }
    
    @IBAction func volumeSliderEndEditing(sender: UISlider) {
        Global.musicPlayer?.setNewTime(progress: sender.value)
        changeCurrentTime = false
        startTimer()
    }
    
    @IBAction func volumeSliderStartEditing(sender: UISlider) {
        changeCurrentTime = true
        timer?.invalidate()
        
        currentTimeLabel.text = Global.musicPlayer?.getCurrentTimeAsString(progress: currentTimeSlider.value)
        timeLeftLabel.text = Global.musicPlayer?.getLeftTimeAsString(progress: currentTimeSlider.value)
    }
    
    @IBAction func setVolumeAction(sender: UISlider) {
        if let view = masterVolumeSlider.subviews.first as? UISlider {
            view.value = sender.value
            view.sendActions(for: UIControlEvents.touchUpInside)
        }
    }
    
    @IBAction func hideButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButton(sender: UIBarButtonItem) {
        downloadSong()
    }
}
