//
//  ScreenshotWatcher.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

protocol ScreenshotWatcherDelegate {
    func screenshotUploaded()
}

class ScreenshotWatcher {
    var unexpandedDirectoryToWatch = "~/Desktop"
    var fileNamesAtPath: [String] = []
    
    var directoryToWatch : String
    
    var delegate : ScreenshotWatcherDelegate?
    
    init() {
        directoryToWatch = (unexpandedDirectoryToWatch as NSString).expandingTildeInPath
        
        do {
            try fileNamesAtPath = FileManager.default.contentsOfDirectory(atPath: directoryToWatch)
        } catch let e {
            print("Exception while trying to watch directory! \(e)")
        }
    }
    
    func start() {
        DirectoryMonitor(at: URL(fileURLWithPath: directoryToWatch)).startMonitoring {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(500)) {
                do {
                    let newFilesAtPath = try FileManager.default.contentsOfDirectory(atPath: self.directoryToWatch)
                    
                    for newElem in newFilesAtPath {
                        if !self.fileNamesAtPath.contains(newElem) {
                            if newElem[newElem.startIndex] == "." {
                                continue
                            }
                            
                            let fullElemPath = (self.directoryToWatch as NSString).appendingPathComponent(newElem);
                            
                            let attrNames = ExtendedAttributes.attributesNamesAtPath(path: fullElemPath);
                            
                            if attrNames.names != nil {
                                if attrNames.names!.contains("com.apple.metadata:kMDItemIsScreenCapture") || attrNames.names!.contains("com.apple.metadata:kMDItemScreenCaptureGlobalRect") || attrNames.names!.contains("com.apple.metadata:kMDItemScreenCaptureType") {
                                    try? LatteShare.sharedInstance.getConnection().uploadFile(filePath: fullElemPath, success: { url in
                                        
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.writeObjects([url as NSPasteboardWriting])
                                        
                                        let notification = NSUserNotification()
                                        
                                        notification.title = "Upload Successful!"
                                        notification.informativeText = "Your screenshot was successfully uploaded."
                                        notification.soundName = NSUserNotificationDefaultSoundName
                                        
                                        NSUserNotificationCenter.default.deliver(notification)
                                        
                                        let ri = RecentItems()
                                        
                                        ri.addRecentItem(identifier: url, date: NSDate())
                                        ri.save()
                                        
                                        self.delegate?.screenshotUploaded()
                                        
                                        let aa = LocalSettings.getSettings()?.afterAction
                                        
                                        if aa == .MoveToTrash {
                                            do {
                                                try FileManager.default.trashItem(at: URL(fileURLWithPath: fullElemPath), resultingItemURL: nil)
                                            } catch let e {
                                                print("Exception while trashing item! \(e)")
                                            }
                                        } else if aa == .DeleteFromDisk {
                                            do {
                                                try FileManager.default.removeItem(atPath: fullElemPath)
                                            } catch let e {
                                                print("Exception while removing item! \(e)")
                                            }
                                        }
                                        
                                    }, failure: { error in
                                        
                                        let notification = NSUserNotification()
                                        
                                        notification.title = "Upload Error!"
                                        notification.informativeText = error
                                        
                                        NSUserNotificationCenter.default.deliver(notification)
                                        
                                    })
                                }
                            }
                        }
                    }
                    
                    self.fileNamesAtPath = newFilesAtPath
                } catch let e {
                    print("Exception while observing change! \(e)")
                }
            }
        }
    }
}
