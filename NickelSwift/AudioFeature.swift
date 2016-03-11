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
    
    init() {
        
    }
    
    func setupFeature(nickelViewController:NickelWebViewController){
        nickelViewController.registerBridgedFunction("playSound", bridgedMethod: self.playSound)
    }

    
    func playSound(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{
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