//
//  NotificationManager.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/13/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import WebKit

class NotificationManager: NSObject {

    var pendingNotification: WebPageReminder?
    
    static let sharedInstance = NotificationManager()

    func addReminder(time: NSDate, navigationItem: WKBackForwardListItem ){
        let notification  = UILocalNotification()
        notification.fireDate = time
        notification.alertTitle = navigationItem.title
        notification.alertBody = navigationItem.URL.host
        notification.applicationIconBadgeNumber = 1
        notification.userInfo = ["url" : navigationItem.URL.absoluteString,
            "host" : navigationItem.URL.host!,
            "title":navigationItem.title!]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
}

class WebPageReminder {
    var host:NSString?
    var url:NSString?
    var title:NSString?
}
