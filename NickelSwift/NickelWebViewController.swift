//
//  PolymerWebView.swift
//  PolymerIos
//
//  Created by Riana Ralambomanana on 17/12/2015.
//  Copyright © 2016 Riana.io. All rights reserved.
//

import Foundation

import WebKit

struct TransferData {
    
    var timeStamp:Int = 0
    
    var operation:String = "NOOP"
    
    var callback:Bool = false
    
    var data:AnyObject?
}

public typealias BridgedMethod = (String, AnyObject) -> AnyObject?

public class NickelWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate{
    
    var myWebView:WKWebView?;
    
    var bridgedMethods = [String: BridgedMethod]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.addScriptMessageHandler(self, name: "native")
        theConfiguration.allowsInlineMediaPlayback = true
        
        myWebView = WKWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height), configuration: theConfiguration)
        myWebView?.scrollView.bounces = false
        
        myWebView?.navigationDelegate = self
        
        
        self.view.addSubview(myWebView!)
    }
    
    public func setMainPage(name:String){
        let localUrl = NSBundle.mainBundle().URLForResource(name, withExtension: "html");
        //        let requestObj = NSURLRequest(URL: localUrl!);
        //        myWebView!.loadRequest(requestObj);
        myWebView!.loadFileURL(localUrl!, allowingReadAccessToURL: localUrl!)
    }
    
    
    
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let stringData = message.body as! String;
        let receivedData = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments) as! [NSObject: AnyObject]
            
            var transferData = TransferData()
            if let timeStamp = jsonData["timestamp"] as? Int {
                transferData.timeStamp = timeStamp
            }
            
            if let operation = jsonData["operation"] as? String {
                transferData.operation = operation
            }
            
            if let callback = jsonData["callback"] as? Bool {
                transferData.callback = callback
            }
            
            if let data = jsonData["data"] {
                transferData.data = data
            }
            
            // print("\(transferData)")
            
            if let bridgedMethod = bridgedMethods[transferData.operation] {
                if let result = bridgedMethod(transferData.operation, transferData.data!) {
                    if(transferData.callback){
                        sendtoView("\(transferData.operation)-\(transferData.timeStamp)", data:result);
                    }
                }
            }else {
                print("Bridged operation not found : \(transferData.operation)")
            }
            
        }catch{
            print("error serializing JSON: \(error)")
        }
    }
    
    public func sendtoView(operation:String, data:AnyObject){
        
        let jsonProperties:AnyObject = ["operation": operation, "data": data]
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonProperties,options:NSJSONWritingOptions())
            let jsonString =  NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            let callbackString = "window.NativeBridge.handleMessage"
            let jsFunction = "(\(callbackString)(\(jsonString)))";
            //          print(jsFunction)
            myWebView!.evaluateJavaScript(jsFunction) { (JSReturnValue:AnyObject?, error:NSError?)-> Void in
                if let errorDescription = error?.description{
                    print("returned value: \(errorDescription)")
                }
            }
        } catch let error {
            print("error converting to json: \(error)")
        }
    }
    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // JS function Initialized
        sendtoView("Initialized", data:["status" : "ok"])
        didFinishLoading()
    }
    
    public func registerBridgedFunction(operationId:String, bridgedMethod:BridgedMethod){
        bridgedMethods[operationId] = bridgedMethod
    }
    
    public func didFinishLoading() {
        
    }
    
    
    
}


