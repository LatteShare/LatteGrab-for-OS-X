//
//  LocalSettings.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 19/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class LocalSettings {
    
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    enum AfterScreenshotUploadAction {
        case DoNothing
        case MoveToTrash
        case DeleteFromDisk
    }
    
    init() {
        
    }
    
}
