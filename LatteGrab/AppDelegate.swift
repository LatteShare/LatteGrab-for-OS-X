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
    
    var ssw : ScreenshotWatcher?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        ssw = ScreenshotWatcher()
        
        ssw!.start()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

