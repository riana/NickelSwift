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
    
    var data:[NSObject:AnyObject]?
}

public typealias BridgedMethod = (String, [NSObject:AnyObject]) -> [NSObject:AnyObject]?

public protocol NickelFeature {
    
    var exposedFunctions: [String: BridgedMethod] { get }
    
    var nickelView:NickelWebViewController? { get set}
    
}

public class NickelWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var myWebView:WKWebView?;
    
    var timer:NSTimer?
    
    var elapsedTime:Int = 0
    
    let imagePicker = UIImagePickerController()
    
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
    
    public func registerFeature(var feature:NickelFeature){
        feature.nickelView = self
        for (functionName, exposedFunction) in feature.exposedFunctions {
            registerBridgedFunction(functionName, bridgedMethod: exposedFunction)
        }
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
            
            if let data = jsonData["data"] as? [NSObject:AnyObject]{
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
            
            let callbackString = "window.NickelBridge.handleMessage"
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
        doRegisterFeatures()
        
        registerBridgedFunction("pickImage", bridgedMethod: self.pickImage)
        registerBridgedFunction("startTimer", bridgedMethod: self.startTimer)
        registerBridgedFunction("stopTimer", bridgedMethod: self.stopTimer)
        
        registerFeature(StorageFeature())
        registerFeature(LocalNotificationFeature())
    }
    
    public func registerBridgedFunction(operationId:String, bridgedMethod:BridgedMethod){
        bridgedMethods[operationId] = bridgedMethod
    }
    
    public func doRegisterFeatures() {
        
    }
    
    
    /**
     * Select image feature
     **/
    func pickImage(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        return [NSObject:AnyObject]()
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageResized = resizeImage(pickedImage, newWidth: 100)
            let imageData = UIImagePNGRepresentation(imageResized)
            let base64String = imageData!.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            
            let imagesString = "data:image/png;base64,\(base64String)"
            sendtoView("imagePicked", data:["image" :imagesString ])
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     * END Select image feature
     **/
    
     /**
     * Native Timer feature
     **/
    func startTimer(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        self.elapsedTime = 0
        timer =  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerTick"), userInfo: nil, repeats: true)
        
        return [NSObject:AnyObject]()
    }
    
    func stopTimer(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        timer?.invalidate()
        sendtoView("timerComplete", data:["elapsedTime" : self.elapsedTime]);
        return [NSObject:AnyObject]()
    }
    
    func timerTick(){
        self.elapsedTime++;
        sendtoView("timeStep", data:["elapsedTime" : self.elapsedTime]);
    }
    
    /**
    * END Native Timer feature
    **/

    
}


