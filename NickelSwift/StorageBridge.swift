//
//  StorageBridge.swift
//  NickelDemo
//
//  Created by Riana Ralambomanana on 23/01/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

import SwiftyJSON

class StorageBridge: NickelFeature {
    
    var store:NickelStore?;
    
    var exposedFunctions:[String: BridgedMethod] = [String: BridgedMethod]()
    
    var nickelView:NickelWebViewController? {
        
        set(newNickelView) {
        
        }
        
        get {
            return self.nickelView
        }

    }
    
    init() {
        store = NickelStore()
        exposedFunctions["storeObject"] = self.storeObject;
        exposedFunctions["loadAllObjects"] = self.loadAllObjects;
        exposedFunctions["deleteObject"] = self.deleteObject;
    }
    
    func storeObject(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let id = content["id"] as! String
        let data = content["data"] as! String
        let indexed = content["indexed"] as! [String]
        
        self.store!.save(type, id: id, data: data, indexed: indexed)
        return [NSObject:AnyObject]()
    }
    
    func deleteObject(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let id = content["id"] as! String
        self.store!.delete(type, id: id)
        return [NSObject:AnyObject]()
    }
    
    
    func loadAllObjects(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let content = self.store!.loadAll(type)
        let jsonContent = JSON(content)
        if let stringResult = jsonContent.rawString() {
            print(stringResult)
            return ["data" : stringResult]
        }
        
        return [NSObject:AnyObject]()
    }
    
    
}