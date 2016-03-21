//
//  i18nFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 20/03/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation


import Foundation

import AVFoundation

class i18nFeature: NickelFeature {
    
    
    
    init() {
    }
    
    
    func setupFeature(nickelViewController:NickelWebViewController){
//        let testContent = [NSObject:AnyObject]()
//        self.getLanguage("test", content: testContent)
        nickelViewController.registerBridgedFunction("getLanguage", bridgedMethod: self.getLanguage)
    }
    
    
    func getLanguage(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let langId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        let countryId = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        let language = "\(langId)-\(countryId)"
        print(language)
        return ["lang": langId, "country": countryId]
    }
    
}