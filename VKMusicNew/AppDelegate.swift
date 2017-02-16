//
//  AppDelegate.swift
//  VKMusicNew
//
//  Created by Pavel Aristov on 03.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import CoreData
import DrawerController
import AVFoundation
import RealmSwift

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var drawerController: DrawerController!
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!.absoluteString)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setActive(true)
            
        } catch {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
        //Global.token = nil
        
        if Global.token != nil {
            self.loadDrawerController()
        }
        else {
            self.window?.rootViewController = self.mainStoryBoard.instantiateViewController(withIdentifier: Global.ControllersIdentifiers.AuthContoller.rawValue)
        }
        
        return true
    }

    func loadDrawerController(parentViewController: UIViewController? = nil) {
        let menuVC = mainStoryBoard.instantiateViewController(withIdentifier: "menu")
        let myMusicController = mainStoryBoard.instantiateViewController(withIdentifier: "myMusicController")
        
        self.drawerController = DrawerController(centerViewController: myMusicController, leftDrawerViewController: menuVC)
        
        self.drawerController.maximumLeftDrawerWidth = 230
        
        self.drawerController.openDrawerGestureModeMask = .all
        self.drawerController.closeDrawerGestureModeMask = .all
        
        self.drawerController.showsShadows = false
        self.drawerController.modalTransitionStyle = .flipHorizontal
        
        if parentViewController == nil {
            self.window?.rootViewController = drawerController
        }
        else {
            parentViewController?.present(drawerController, animated: true, completion: nil)
        }
    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

//    // MARK: - Core Data stack
//
//    @available(iOS 10.0, *)
//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "VKMusicNew")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                 
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

}

