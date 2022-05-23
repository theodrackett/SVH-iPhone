//
//  AppDelegate.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/5/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseUI
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //  AppDelegate.m
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UINavigationBar.appearance().backgroundColor = UIColor.black
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.eventGold]
        UINavigationBar.appearance().tintColor = UIColor.black
        UIBarButtonItem.appearance().tintColor = UIColor.eventGold
        UISearchBar.appearance().tintColor = UIColor.eventGold
        //        UIApplication.shared.statusBarStyle = .lightContent
        //        UIView.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().isOpaque = true
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    override init() {
        super.init()
        FirebaseApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.activateApp()
        //        AppEventsLogger.activate(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

