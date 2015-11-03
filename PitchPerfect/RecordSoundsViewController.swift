//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ostap Horbach on 10/20/15.
//  Copyright © 2015 Ostap Horbach. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        recordButton.enabled = true
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordTapped(sender: UIButton) {
        recordButton.enabled = false
        stopButton.hidden = false
        recordingLabel.hidden = false
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            session.requestRecordPermission({ [unowned self] (allowed: Bool) -> Void in
                self.startRecording()
            })
        } catch {
            print("Failed to setup recorder")
        }
    }

    func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let currentDayTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDayTime) + ".m4a"
        let filePath = NSURL.fileURLWithPathComponents([dirPath, recordingName])
        
        //Setup Audio session
        
        let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
        
        do {
            try audioRecorder = AVAudioRecorder.init(URL: filePath!, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            print("Failed to initialise audio recorder")
        }
    }

    @IBAction func stopTapped(sender: UIButton) {
        recordingLabel.hidden = true
        recordButton.enabled = true
        stopButton.hidden = true
        
        audioRecorder.stop()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Finished recording")
            
            recordedAudio = RecordedAudio()
            recordedAudio.filePathUrl = recorder.url
            recordedAudio.titleString = recorder.url.lastPathComponent
            
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}

