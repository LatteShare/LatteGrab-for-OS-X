//
//  SettingsController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 11/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class SettingsController: NSObject {
    
    var defaults : NSUserDefaults!
    
    @IBOutlet var openAtLoginButton : NSButton!
    
    static let kOpenAtLoginKey = "Open at Login"
    
    override func awakeFromNib() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if defaults.boolForKey(SettingsController.kOpenAtLoginKey) {
            //  openAtLoginButton
        }
    }
    
}
