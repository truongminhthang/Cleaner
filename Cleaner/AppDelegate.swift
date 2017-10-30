//
//  AppDelegate.swift
//  Cleaner
//
//  Created by Truong Thang on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos
import UserNotifications
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var isFakeModeApp : Bool = true
    var isDashboardDisplay: Bool = false
    static var shared = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .default
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){ (allowed, error) in
            UNUserNotificationCenter.current().delegate = self
            self.scheduleNotification()
        }
        
        application.applicationIconBadgeNumber = 0
           GoogleAdMob.sharedInstance.showInterstitial()
        
        return true
    }
    
    func scheduleNotification() {
        var date = DateComponents()
        date.year = date.year
        date.month = date.month
        date.day = date.day
        date.hour = 11
        date.minute = 25
        date.timeZone = NSTimeZone.system
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Cleaner"
        content.body = "Warning: Free your memory and RAM to speed up."
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("error: \(error)")
            }
        }
        
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        GoogleAdMob.sharedInstance.showInterstitial()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

