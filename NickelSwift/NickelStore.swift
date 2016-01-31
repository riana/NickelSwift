//
//  ObjectStorage.swift
//  coco
//
//  Created by Riana Ralambomanana on 22/01/2016.
//  Copyright © 2016 Riana.io. All rights reserved.
//

import Foundation

import RealmSwift
import SwiftyJSON


class StoredObject: Object {
    dynamic var id = ""
    dynamic var type = ""
    dynamic var data = ""
    dynamic var clientDate:Int64 = 0
    dynamic var date:Int64 = 0
    dynamic var updateDate:Int64 = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["id", "type"]
    }
    
}

class ObjectIndex: Object {
    dynamic var id = ""
    dynamic var refId = ""
    dynamic var refType = ""
    dynamic var propertyName = ""
    dynamic var stringPropertyValue = ""
    dynamic var numberPropertyValue = 0.0
    
    override static func indexedProperties() -> [String] {
        return ["refId", "refType", "propertyName", "stringPropertyValue"]
    }
    
}

public class NickelStore {
    
    let realm:Realm
    
    public init() {
        self.realm = try! Realm()
    }
    
    public static func drop() {
        let manager = NSFileManager.defaultManager()
        //        let realmPath = Realm.Configuration.defaultConfiguration.path as! NSString
        let realmPath = Realm.Configuration.defaultConfiguration.path! as NSString
        let realmPaths = [
            realmPath as String,
            realmPath.stringByAppendingPathExtension("lock")!,
            realmPath.stringByAppendingPathExtension("log_a")!,
            realmPath.stringByAppendingPathExtension("log_b")!,
            realmPath.stringByAppendingPathExtension("note")!
        ]
        for path in realmPaths {
            do {
                try manager.removeItemAtPath(path)
            } catch {
                // handle error
            }
        }
    }
    
    
    public func save(type: String, id: String, data: String, indexed: [String]){
        
        var storedObject = StoredObject()
        try! realm.write {
            let jsonData = JSON.parse(data).rawValue as! [NSObject:AnyObject]
            let todayTimeStampDouble = NSDate().timeIntervalSince1970
            let todayTimeStamp = Int64(todayTimeStampDouble*1000)
            // If  exists in DB then get the matching instance
            let inDBObjects = realm.objects(StoredObject).filter("type = '\(type)' and id = '\(id)'")
            
            if(inDBObjects.count == 1){
                storedObject = inDBObjects[0];
                storedObject.updateDate = todayTimeStamp
            }else {
                storedObject.id = id
                storedObject.date = todayTimeStamp
                storedObject.updateDate = todayTimeStamp
                
            }
            
            if let clientDate = jsonData["_clientDate"] as? NSNumber {
                storedObject.clientDate = clientDate.longLongValue
            }
            
            
            storedObject.type = type
            storedObject.data = data
            
            var storedIndices = [ObjectIndex]()
            
            for indexedPropertyName in indexed {
                
                let index = self.extractIndexData(jsonData, propertyName: indexedPropertyName)
                
                var storedIndex = ObjectIndex()
                
                // If  exists in DB then get the matching instance
                let inDBIndex = realm.objects(ObjectIndex).filter("refType = '\(type)' and refId = '\(id)' and propertyName = '\(index["name"] as! String)'")
                if(inDBIndex.count == 1) {
                    storedIndex = inDBIndex[0];
                }else{
                    storedIndex.id = NSUUID().UUIDString
                }
                storedIndex.refId = id
                storedIndex.refType = type
                storedIndex.propertyName = index["name"] as! String
                
                let refType = index["type"] as! String
                if( refType == "String"){
                    storedIndex.stringPropertyValue = index["value"] as! String
                }else if(refType == "Number"){
                    storedIndex.numberPropertyValue = index["value"] as! Double
                }
                storedIndices.append(storedIndex)
            }
            
            
            realm.add(storedIndices)
            realm.add(storedObject, update: true)
        }
        
    }
    
    public func delete(type: String, id: String){
        let inDBObjects = realm.objects(StoredObject).filter("type = '\(type)' and id = '\(id)'")
        let inDBIndices = realm.objects(ObjectIndex).filter("refType = '\(type)' and refId = '\(id)'")
        
        try! realm.write {
            for obj in inDBObjects {
                realm.delete(obj)
            }
            for index in inDBIndices {
                realm.delete(index)
            }
        }
    }
    
    public func loadAll(type: String) -> [AnyObject]{
        return self.findFromObjectQuery("type = '\(type)'");
    }
    
    public func findById(type: String, id: String) -> [AnyObject] {
        return self.findFromObjectQuery("type = '\(type)' and id = '\(id)'");
    }
    
    
    public func findByStringProperty(type: String, property: String, value: String) -> [AnyObject] {
        return self.findFromIndexQuery(type, query: "refType = '\(type)' and propertyName = '\(property)' and stringPropertyValue = '\(value)'")
    }
    
    
    public func findByNumberProperty(type: String, property: String, value: Double) -> [AnyObject] {
        return self.findFromIndexQuery(type, query: "refType = '\(type)' and propertyName = '\(property)' and numberPropertyValue = \(value)")
    }
    
    public func findByNumberPropertyRange(type: String, property: String, min: Double, max: Double) -> [AnyObject] {
        return self.findFromIndexQuery(type, query: "refType = '\(type)' and propertyName = '\(property)' and numberPropertyValue > \(min) and numberPropertyValue < \(max)" )
    }
    
    func extractIndexData(data: [NSObject:AnyObject], propertyName: String) -> NSDictionary {
        
        
        var indexData = [NSObject:AnyObject]()
        
        indexData["name"] = propertyName
        indexData["type"] = "unknown"
        let propertyValue = data[propertyName]
        
        if let val = propertyValue as? String {
            indexData["type"] = "String"
            indexData["value"] = val
        } else if let val = propertyValue as? Double {
            indexData["type"] = "Number"
            indexData["value"] = val
        }
        return indexData
    }
    
    func findFromObjectQuery(query: String) -> [AnyObject]{
        let allObjects = realm.objects(StoredObject).filter(query)
        var jsonArray = [AnyObject]()
        for obj in allObjects {
            var jsonData = JSON.parse(obj.data).rawValue as! [NSObject:AnyObject]
            jsonData["_id"] = obj.id
            jsonData["_date"] = NSNumber(longLong:obj.date)
            jsonData["_updateDate"] = NSNumber(longLong:obj.updateDate)
            jsonData["_clientDate"] = NSNumber(longLong:obj.clientDate)
            jsonArray.append(jsonData)
        }
        return jsonArray
    }
    
    
    func findFromIndexQuery(type: String, query: String)-> [AnyObject] {
        var jsonArray = [AnyObject]()
        
        let allIndices = realm.objects(ObjectIndex).filter(query)
        
        for index in allIndices {
            let targetId = index.refId
            let allObjects = self.findById(type, id: targetId)
            for obj in allObjects {
                jsonArray.append(obj)
            }
        }
        return jsonArray
    }
    
    
    
    
    
    
}