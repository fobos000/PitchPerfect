//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Ostap Horbach on 10/24/15.
//  Copyright © 2015 Ostap Horbach. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var leftLevelView: UIProgressView!
    @IBOutlet weak var rightLevelView: UIProgressView!
    @IBOutlet weak var stopButton: UIButton!
    
    var receivedAudio:RecordedAudio!
    var player:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try player = AVAudioPlayer.init(contentsOfURL: receivedAudio.filePathUrl)
            player.enableRate = true
            player.meteringEnabled = true
            player.prepareToPlay()
        } catch {
            print("Failed to initialise player")
        }
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
    
    @IBAction func slowPlaybackTapped(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }
    
    @IBAction func fastPlaybackTapped(sender: UIButton) {
        playAudioWithVariableRate(2.0)
    }
    
    @IBAction func chipmunkTapped(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func darthvaderTapped(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopTapped(sender: UIButton) {
        stopPlayback()
    }
    
    func stopPlayback() {
        audioEngine.stop()
        audioEngine.reset()
        player.stop()
        player.currentTime = 0
    }
    
    func playAudioWithVariableRate(rate: Float) {
        stopPlayback()
        player.rate = rate
        player.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        stopPlayback()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }
}
