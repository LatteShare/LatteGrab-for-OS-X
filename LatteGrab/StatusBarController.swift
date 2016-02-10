//
//  StatusBarController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class StatusBarController: NSObject {
    
    @IBOutlet weak var menu : NSMenu?
    
    @IBOutlet weak var recentFilesMenuItem : NSMenuItem?
    @IBOutlet weak var recentItemMenuItem : NSMenuItem?
    
    override func awakeFromNib() {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        statusItem.title = "LG"
        statusItem.menu = menu
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func openSettings(sender: NSMenuItem) {
        
    }
    
}
