//
//  AwakeFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 09/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

class AwakeFeature: NickelFeature {
    
    init() {

    }
    
    func setupFeature(nickelViewController:NickelWebViewController){
        nickelViewController.registerBridgedFunction("enableAwakeMode", bridgedMethod: self.enableAwakeMode)
        nickelViewController.registerBridgedFunction("disableAwakeMode", bridgedMethod: self.disableAwakeMode)
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