//
//  AppDelegate.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var ssw : ScreenshotWatcher!
    
    @IBOutlet var sbc : StatusBarController!
    @IBOutlet var ac : AuthenticationController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        ssw = ScreenshotWatcher()
        
        ssw.start()
        
        ssw.delegate = sbc
        ac.delegate = sbc
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

