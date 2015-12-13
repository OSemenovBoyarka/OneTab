//
//  AppDelegate.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[.Sound, .Alert, .Badge], categories: nil))
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let url = notification.userInfo!["url"] as! String
        let host = notification.userInfo!["host"] as! String
        let title = notification.userInfo!["title"] as! String
        NSLog("didReceiveLocalNotification with url: %@, title %@, host: %@", url, title, host)
        NSNotificationCenter.defaultCenter().postNotificationName("receiveReminder", object: self, userInfo: notification.userInfo)
    }


}

