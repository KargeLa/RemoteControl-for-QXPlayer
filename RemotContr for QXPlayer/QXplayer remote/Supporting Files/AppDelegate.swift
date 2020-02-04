//
//  AppDelegate.swift
//  QXplayer remote
//
//  Created by Sergei Morozov on 12/27/19.
//  Copyright © 2019 MDSolution. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

 var window : UIWindow?
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBar = UITabBar.appearance()
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle


}

