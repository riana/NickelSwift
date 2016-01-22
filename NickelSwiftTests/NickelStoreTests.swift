//
//  cocoTests.swift
//  cocoTests
//
//  Created by Riana Ralambomanana on 22/01/2016.
//  Copyright © 2016 Riana.io. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import NickelSwift

class cocoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStore() {
        NickelStore.drop()
        
        let store = NickelStore()
        
        let objectType = "Person"
        let jsonData = JSON(["firstName": "John", "age" : 25])
        let objectId = NSUUID().UUIDString
        
        let indexedAttributes = ["firstName", "age"]
        
        if let jsonString = jsonData.rawString() {
            print(jsonString)
            store.save(objectType, id: objectId, data: jsonString, indexed: indexedAttributes);
        }
        
        var content = store.loadAll(objectType)
        var jsonContent = JSON(content)
        if let stringResult = jsonContent.rawString() {
            print(stringResult)
        }
        XCTAssertEqual(1, content.count, "The store should contain 1 item")
        
        jsonContent[0]["age"] = 35
        
        store.save(objectType, id: objectId, data: jsonContent[0].rawString()!, indexed: indexedAttributes);
        
        content = store.loadAll(objectType)
        XCTAssertEqual(1, content.count, "Should have updated the existing record")
        
        content = store.findById(objectType, id: objectId);
        XCTAssertEqual(1, content.count, "The query should return 1 item")
        
        content = store.findById(objectType, id: "fail");
        XCTAssertEqual(0, content.count, "The query should return 0 item")
        
        content = store.findByStringProperty(objectType, property: "firstName", value:"John")
        XCTAssertEqual(1, content.count, "The query should return 1 item")
        
        content = store.findByStringProperty(objectType, property: "firstName", value:"Jane")
        XCTAssertEqual(0, content.count, "The query should return 0 item")
        
        
        content = store.findByNumberProperty(objectType, property: "age", value:35)
        XCTAssertEqual(1, content.count, "The query should return 1 item")
        
        content = store.findByNumberProperty(objectType, property: "age", value:12)
        XCTAssertEqual(0, content.count, "The query should return 0 item")
        
        content = store.findByNumberPropertyRange(objectType, property: "age", min:12, max: 37)
        XCTAssertEqual(1, content.count, "The query should return 1 item")
        
        content = store.findByNumberPropertyRange(objectType, property: "age", min:12, max: 22)
        XCTAssertEqual(0, content.count, "The query should return 0 item")
        
        store.delete(objectType, id: objectId)
        content = store.loadAll(objectType)
        XCTAssertEqual(0, content.count, "No more instances should be available in the store")
        
    }
    
    func testExtractIndexFromJSON() {
        
        let store = NickelStore()
        
        let data = JSON(["firstName": "John", "age" : 25])
        let jsonData = data.rawValue as! [NSObject:AnyObject]
        let indexData = store.extractIndexData(jsonData, propertyName: "firstName")
        
        
        XCTAssertEqual("firstName", indexData["name"] as? String, "type of attribute should be string")
        XCTAssertEqual("String", indexData["type"] as? String, "type of attribute should be string")
        XCTAssertEqual("John", indexData["value"] as? String, "type of attribute should be string")
        
    }
    
}
