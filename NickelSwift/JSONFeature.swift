//
//  JSONFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 06/03/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

import AVFoundation

class JSONFeature: NickelFeature {
    
    var exposedFunctions:[String: BridgedMethod] = [String: BridgedMethod]()
    
    var nickelView:NickelWebViewController? {
        
        set(newNickelView) {
            
        }
        
        get {
            return self.nickelView
        }
        
    }
    
    init() {
        exposedFunctions["loadJson"] = self.loadJson
    }
    
    func loadJson(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let fileName = content["file"] as! String
        
        do {
            print(fileName)
            let path = NSBundle.mainBundle().pathForResource("www/\(fileName)", ofType: "json")
            if path != nil {
                let fileContent = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                return ["data" : fileContent]
            }else {
                return ["error" : "File not found"]
            }
        }
        catch {
            print("Error loading file")
        }
        return [NSObject:AnyObject]()
    }
    
}