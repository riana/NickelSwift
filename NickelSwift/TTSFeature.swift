//
//  NickelTTS.swift
//  NickelSwift
//
//  Created by Riana Ralambomanana on 15/02/2016.
//  Copyright © 2016 riana.io. All rights reserved.
//

import Foundation

import AVFoundation

class TTSFeature: NickelFeature {
    
    let synth = AVSpeechSynthesizer()
    
    let voice = AVSpeechSynthesisVoice(language: "en-US")
    
    
    init() {
    }
    
    
    func setupFeature(nickelViewController:NickelWebViewController){
        nickelViewController.registerBridgedFunction("speak", bridgedMethod: self.speak)
    }
    
    func speak(operation:String, content:[NSObject:AnyObject]) -> [NSObject:AnyObject]?{

        let text = content["text"] as! String
//        let language = content["language"] as! String
        
        let myUtterance = AVSpeechUtterance(string: text)
                myUtterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
//        myUtterance.voice = voice
        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.speakUtterance(myUtterance)
        return [NSObject:AnyObject]()
    }
    
}