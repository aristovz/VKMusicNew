//
//  AuthorizationController.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 03.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit

class AuthorizationController: UIViewController, UIWebViewDelegate {
    
    var webView = UIWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: self.view.frame)
    }
    
    @IBAction func authButtonAction(_ sender: UIButton) {
        webView.delegate = self
        
        let url = URL(string: "http://oauth.vk.com/authorize?client_id=\(Global.appID)&scope=friends,audio,offline&redirect_uri=http://api.vk.com/blank.html&display=page&response_type=token&v=\(Global.currentVersion)")!
        
        //"https://oauth.vk.com/token?grant_type=password&2fa_supported=1&client_id=3697615&client_secret=AlVXZFMUqyrnABp8ncuU&scope=audio,wall,friends,groups,offline,status&v=5.63&password=\(password)&username=\(username)")
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
        self.view.addSubview(webView)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url = request.url!.absoluteString.replacingOccurrences(of: "#", with: "?")
        
        print(url)
        
        let queryItems = URLComponents(string: url)?.queryItems
        let token = queryItems?.filter({$0.name == "access_token"}).first
        let user_id = queryItems?.filter({$0.name == "user_id"}).first
        print("\(token?.value) | \(user_id?.value)")
        
        if (token?.value != nil && user_id?.value != nil) {
            Global.token = token!.value!
            Global.user_id = Int(user_id!.value!)
            
            Global.appDelegate.loadDrawerController(parentViewController: self)
        }
        
        return true
    }
    
}
