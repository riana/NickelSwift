//
//  StorageBridge.swift
//  NickelDemo
//
//  Created by Riana Ralambomanana on 23/01/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

import SwiftyJSON

class StorageFeature: NickelFeature {
    
    var store:NickelStore?;
    
    
    init() {
        self.store = NickelStore()
    }
    
    func setupFeature(nickelViewController:NickelWebViewController){
        nickelViewController.registerBridgedFunction("storeObject", bridgedMethod: self.storeObject)
        nickelViewController.registerBridgedFunction("loadAllObjects", bridgedMethod: self.loadAllObjects)
        nickelViewController.registerBridgedFunction("deleteObject", bridgedMethod: self.deleteObject)
        nickelViewController.registerBridgedFunction("queryIndex", bridgedMethod: self.queryIndex)
        nickelViewController.registerBridgedFunction("queryObject", bridgedMethod: self.queryObject)
        nickelViewController.registerBridgedFunction("dropDatabase", bridgedMethod: self.dropDatabase)
    }
    
    func dropDatabase(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        NickelStore.drop()
        self.store = NickelStore()
        return [NSObject:AnyObject]()
    }
    
    func storeObject(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let id = content["id"] as! String
        let data = content["data"] as! String
        let indexed = content["indexed"] as! [String]
        
        self.store!.save(type, id: id, data: data, indexed: indexed)
        return [NSObject:AnyObject]()
    }
    
    func queryIndex(operation:String, content:[NSObject:AnyObject]) ->  [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let q = content["query"] as! String
        let result = self.store?.findFromIndexQuery(type, query: q)
        let jsonContent = JSON(result!)
        if let stringResult = jsonContent.rawString() {
            //            print("query \(stringResult)")
            return ["data" : stringResult]
        }
        return [NSObject:AnyObject]()
    }
    
    func queryObject(operation:String, content:[NSObject:AnyObject]) ->  [NSObject:AnyObject]?{
        let type = content["type"] as! String
        let q = content["query"] as! String
        let result = self.store?.findFromObjectQuery("type = '\(type)' and \(q)")
        let jsonContent = JSON(result!)
        if let stringResult = jsonContent.rawString() {
            //            print("query \(stringResult)")
            return ["data" : stringResult]
        }
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