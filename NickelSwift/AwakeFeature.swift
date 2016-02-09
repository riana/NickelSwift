//
//  AwakeFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 09/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

class AwakeFeature: NickelFeature {
    
    var exposedFunctions:[String: BridgedMethod] = [String: BridgedMethod]()
    
    var nickelView:NickelWebViewController? {
        
        set(newNickelView) {
            
        }
        
        get {
            return self.nickelView
        }
        
    }
    
    init() {
        exposedFunctions["enableAwakeMode"] = self.enableAwakeMode
        exposedFunctions["disableAwakeMode"] = self.disableAwakeMode
    }
    
    func enableAwakeMode(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        UIApplication.sharedApplication().idleTimerDisabled = true
        return [NSObject:AnyObject]()
    }
    
    func disableAwakeMode(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        UIApplication.sharedApplication().idleTimerDisabled = false
        return [NSObject:AnyObject]()
    }

    
    
}