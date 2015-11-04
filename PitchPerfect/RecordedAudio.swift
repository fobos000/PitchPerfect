//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Ostap Horbach on 10/31/15.
//  Copyright © 2015 Ostap Horbach. All rights reserved.
//

import Foundation

class RecordedAudio {
    var filePathUrl: NSURL
    var titleString: NSString
    
    init(filePath: NSURL, title: String) {
        filePathUrl = filePath
        titleString = title
    }
}