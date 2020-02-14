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
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = grubStoryboard().instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        let tabBar = UITabBar.appearance()
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Override point for customization after application launch.
        return true
    }

    private func grubStoryboard() -> UIStoryboard {
        var storyboard = UIStoryboard()
        
        if UIDevice.current.model == "iPad" {
            storyboard = UIStoryboard(name: "iPad", bundle: nil)
        } else if UIDevice.current.model == "iPhone" {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        return storyboard
    }


}

