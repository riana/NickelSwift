//
//  LocalNotificationFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 05/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

class LocalNotificationFeature: NickelFeature {
    
    var exposedFunctions:[String: BridgedMethod] = [String: BridgedMethod]()
    
    var nickelView:NickelWebViewController? {
        
        set(newNickelView) {
            
        }
        
        get {
            return self.nickelView
        }
        
    }
    
    init() {
        exposedFunctions["scheduleNotification"] = self.scheduleNotification
        exposedFunctions["cancelNotification"] = self.cancelNotification
        exposedFunctions["getScheduledNotifications"] = self.getScheduledNotifications
    }
    
    func getScheduledNotifications(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        var response = [NSObject:AnyObject]();
         var notifications = [AnyObject]()
        
        for  notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            notifications.append(notification.userInfo!)
        }
        response["notifications"] = notifications
        return response
    }

    
    func cancelNotification(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let notificationId = content["id"] as! String
        for  notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            let currentId = notification.userInfo!["id"] as! String
            if(currentId == notificationId){
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
        }
        
        return [NSObject:AnyObject]()
    }
    
    func scheduleNotification(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))
        
        let localNotification = UILocalNotification()
        localNotification.userInfo = content
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
        localNotification.alertBody = content["message"] as! String?
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        localNotification.repeatInterval = NSCalendarUnit.Minute
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        return [NSObject:AnyObject]()
    }
    
    
}