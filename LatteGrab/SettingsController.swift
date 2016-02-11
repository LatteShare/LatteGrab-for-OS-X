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
    
    override func awakeFromNib() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            openAtLoginButton.state = NSOnState
        } else {
            openAtLoginButton.state = NSOffState
        }
    }
    
    @IBAction func toggleOpenAtLogin(sender: NSButton!) {
        if !PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            PALoginItemUtility.addCurrentApplicatonToLoginItems()
            
            openAtLoginButton.state = NSOnState
        } else {
            PALoginItemUtility.removeCurrentApplicatonFromLoginItems()
            
            openAtLoginButton.state = NSOffState
        }
    }
    
}
