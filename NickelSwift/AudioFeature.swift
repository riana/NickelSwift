//
//  AudioFeature.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 20/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation
import AVFoundation

class AudioFeature: NickelFeature {
    
    var audioPlayer: AVAudioPlayer!
    
    var exposedFunctions:[String: BridgedMethod] = [String: BridgedMethod]()
    
    var nickelView:NickelWebViewController? {
        
        set(newNickelView) {
            
        }
        
        get {
            return self.nickelView
        }
        
    }
    
    init() {
        exposedFunctions["playSound"] = self.playAudio
    }
    
    func playAudio(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
        let audioFile = content["soundFile"] as! String;
        let path = NSBundle.mainBundle().pathForResource("www/\(audioFile)", ofType:nil)!
        let url = NSURL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer.play()
        } catch {
            print("error loading file")
        }
        return [NSObject:AnyObject]()
    }
    
}