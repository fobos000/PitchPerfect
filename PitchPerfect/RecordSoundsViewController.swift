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
    @IBOutlet weak var tapToRecordLabel: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setIsRecording(false)
    }

    @IBAction func recordTapped(sender: UIButton) {
        setIsRecording(true)
        
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
    
    func setIsRecording(recording: Bool) {
        recordButton.enabled = !recording
        stopButton.hidden = !recording
        tapToRecordLabel.hidden = recording
        recordingLabel.hidden = !recording
    }

    @IBAction func stopTapped(sender: UIButton) {
        setIsRecording(false)
        audioRecorder.stop()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully success: Bool) {
        if success {
            print("Finished recording")
            let recordedAudio = RecordedAudio(filePath: recorder.url, title: recorder.url.lastPathComponent!)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Error while recording audio. Please try again.", comment: "") , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
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

