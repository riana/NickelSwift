//
//  LocalNotificationFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 05/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

class LocalNotificationFeature: NickelFeature {
    
    init() {
       
    }
    
    func setupFeature(nickelViewController:NickelWebViewController){
        nickelViewController.registerBridgedFunction("scheduleNotification", bridgedMethod: self.scheduleNotification)
        nickelViewController.registerBridgedFunction("cancelNotification", bridgedMethod: self.cancelNotification)
        nickelViewController.registerBridgedFunction("getScheduledNotifications", bridgedMethod: self.getScheduledNotifications)
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
        
        
        
        
        if let fireTimeStamp = content["date"] as? NSNumber {
            let fireDate = NSDate(timeIntervalSince1970: NSTimeInterval(fireTimeStamp.longLongValue / 1000))
            let localNotification = UILocalNotification()
            localNotification.userInfo = content
            localNotification.fireDate = fireDate
            localNotification.alertBody = content["message"] as! String?
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            if let repeatInterval = content["repeat"] as! String? {
                if repeatInterval == "Hour"{
                    localNotification.repeatInterval = NSCalendarUnit.Hour
                }
                if repeatInterval == "Minute"{
                    localNotification.repeatInterval = NSCalendarUnit.Minute
                }
                if repeatInterval == "Day"{
                    localNotification.repeatInterval = NSCalendarUnit.Day
                }
                
            }
            
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        return [NSObject:AnyObject]()
    }
    
    
}