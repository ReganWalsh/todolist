//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Regan Walsh on 16/11/2018.
//  Copyright © 2018 Regan Walsh. All rights reserved.
//

import UIKit //Provides Everything Needed To Manage Graphics And Events In iOS
import RealmSwift //Imports Realm For iOS

@UIApplicationMain //"Main" Function In Swift
class AppDelegate: UIResponder, UIApplicationDelegate { //Class Is Used To Store Global Data

    var window: UIWindow? //Initialise Global Window
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions //Callback Method When The Application Has Finished Launching Restored The State, Can Fo Final Initialisation Like Creating UI
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(Realm.Configuration.defaultConfiguration.fileURL as Any) //Print Location Of The Realm Database
        
        do {
            _ = try Realm() //Get The Default Realm
        } catch {
            print("Error initialising new realm, \(error)") //Catch If Error
        }
        return true
    }
}
