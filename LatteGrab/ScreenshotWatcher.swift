//
//  ScreenshotWatcher.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class ScreenshotWatcher : DirectoryMonitorDelegate {
    let directoryMonitor: DirectoryMonitor
    
    var unexpandedDirectoryToWatch = "~/Desktop"
    var fileNamesAtPath: [String] = []
    
    var directoryToWatch : String
    
    init() {
        directoryToWatch = (unexpandedDirectoryToWatch as NSString).stringByExpandingTildeInPath
        
        try! fileNamesAtPath = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryToWatch)
        
        directoryMonitor = DirectoryMonitor(URL: NSURL(fileURLWithPath: directoryToWatch))
        
        directoryMonitor.delegate = self
    }
    
    func start() {
        directoryMonitor.startMonitoring()
    }
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            let newFilesAtPath = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.directoryToWatch)
            
            for newElem in newFilesAtPath {
                if !self.fileNamesAtPath.contains(newElem) {
                    if newElem[newElem.startIndex] == "." {
                        continue
                    }
                    
                    let fullElemPath = (self.directoryToWatch as NSString).stringByAppendingPathComponent(newElem);
                    
                    let attrNames = ExtendedAttributes.attributesNamesAtPath(fullElemPath);
                    
                    if attrNames.names != nil {
                        print(attrNames.1)
                        
                        if attrNames.names!.contains("com.apple.metadata:kMDItemIsScreenCapture") || attrNames.names!.contains("com.apple.metadata:kMDItemScreenCaptureGlobalRect") || attrNames.names!.contains("com.apple.metadata:kMDItemScreenCaptureType") {
                            LatteShare.sharedInstance.getConnection()?.uploadFile(fullElemPath, success: { url in
                                print(url)
                                }, failure: { error in
                                    print(error)
                            })
                        }
                    } else {
                        print(attrNames.error)
                    }
                    
                    self.fileNamesAtPath = newFilesAtPath
                    
                    break
                }
            }
        })
    }
}
