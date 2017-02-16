//
//  MyMusicController.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 29.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class MyMusicController: UITableViewController {

    @IBOutlet weak var lostConnectionView: UIView!
    
    var _musicPlayer: MusicPlayer?
    static var selectedIndex = -1
    
    var imageCache = [IndexPath : UIImage?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch Global.currentTypeOfCenter {
            case .MyMusicController:
                self.title = "Мои аудиозаписи"
                break
            case .PopularController:
                self.title = "Популярные"
                break
            case .SavedController:
                self.title = "Сохраненные"
                break
            default: self.title = "Рекомендованные"
        }
        
        self.tableView.register(UINib(nibName: "musicCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        self.refresh()
    }

    func refresh() {
        checkInternetConnection()
        
        imageCache.removeAll()
        
        if let user_id = Global.user_id {
            if Global.currentTypeOfCenter == .SavedController {
                self._musicPlayer = MusicPlayer(tracks: Array(uiRealm.objects(AudioTrack.self)), fromCache: true)
                self.tableView.reloadData()
                
                self.refreshControl!.endRefreshing()
            }
            else {
                API.Audio.get(owner_id: user_id, requestEnd: { (trackArray) in
                    self._musicPlayer = MusicPlayer(tracks: trackArray)
                    self.tableView.reloadData()
                    
                    self.refreshControl!.endRefreshing()
                })
            }
        }
    }
    
    func showLostConnectionView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor.black
        self.tableView.addSubview(view)
    }
    
    func checkInternetConnection() {
        lostConnectionView.frame = CGRect(x: 0, y: 0, width: lostConnectionView.frame.width, height: 0)
        lostConnectionView.isHidden = true
        if Global.connectedToNetwork() == false {
            lostConnectionView.frame = CGRect(x: 0, y: 0, width: lostConnectionView.frame.width, height: 40)
            lostConnectionView.isHidden = false
            _musicPlayer = nil
            
            return
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return _musicPlayer == nil ? 0 : _musicPlayer!.tracks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1//_musicPlayer == nil ? 0 : _musicPlayer!.tracks.items.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundColor()
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! musicCell
        
        if let player = _musicPlayer {
            let currentTrack = player.tracks[indexPath.section]
            
            cell.titleLabel?.text = currentTrack.title
            cell.artistLabel?.text = currentTrack.artist
            
            let time = Float(currentTrack.duration)
            let seconds = Int(time) % 60
            let minutes = (Int(time) / 60) % 60
            cell.durationLabel.text = String(format: "%0.2d:%0.2d", minutes, seconds)
            cell.numLabel.text = "\(indexPath.section + 1)"
            cell.downloadButtonOutlet.setImage(currentTrack.isDownloaded ? #imageLiteral(resourceName: "heartSelected") : #imageLiteral(resourceName: "heartNoSelected"), for: .normal)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _musicPlayer!.currentTrackIndex = indexPath.section
        
        if Global.musicPlayer == nil || Global.musicPlayer?.currentTrack.id != _musicPlayer!.currentTrack.id {
            Global.musicPlayer = _musicPlayer
        }
        
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: Global.ControllersIdentifiers.NavPlayerController.rawValue)
        present(playerVC!, animated: true, completion: nil)
        
        //self.show(playerVC!, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let currentTrack = self._musicPlayer!.tracks[indexPath.section]
            
            let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            try! FileManager.default.removeItem(atPath: documentPaths[0].appendingFormat("/" + currentTrack.filePath!))
            
            if let player = Global.musicPlayer {
                for track in player.tracks {
                    if track.id == self._musicPlayer?.tracks[indexPath.section].id {
                        if player._fromCache {
                            Global.musicPlayer!.tracks.remove(object: track)
                        }
                        else {
                            track.isDownloaded = false
                        }
                        
                        break
                    }
                }
            }
            
            try! uiRealm.write({ () -> Void in
                uiRealm.delete(currentTrack)
            })
            
            if let player = Global.musicPlayer {
                if !player._fromCache {
                    self._musicPlayer?.tracks.remove(at: indexPath.section)
                }
            }
            
            tableView.beginUpdates()
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func menuOpenButton(sender: UIBarButtonItem) {
        Global.appDelegate.drawerController.toggleLeftDrawerSide(animated: true, completion: nil)
    }
    
    @IBAction func playerButton(sender: UIBarButtonItem) {
        if Global.currentTypeOfCenter == .SavedController {
            self.tableView.setEditing(!tableView.isEditing, animated: true)
        }
        else {
            if Global.musicPlayer == nil { return }
        
            let playerVC = self.storyboard?.instantiateViewController(withIdentifier: Global.ControllersIdentifiers.NavPlayerController.rawValue)
            present(playerVC!, animated: true, completion: nil)
            //self.show(playerVC!, sender: self)
        }
    }
}
