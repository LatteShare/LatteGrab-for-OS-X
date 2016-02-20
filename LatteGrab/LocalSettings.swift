//
//  LocalSettings.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 19/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class LocalSettings : NSObject, NSCoding {
    
    static let kLocalSettingsKey = "Local Settings"
    
    static var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var afterAction : AfterScreenshotUploadAction
    
    enum AfterScreenshotUploadAction : Int {
        case DoNothing
        case MoveToTrash
        case DeleteFromDisk
    }
    
    static func getSettings() -> LocalSettings? {
        if let lsData = defaults.objectForKey(kLocalSettingsKey) as? NSData {
            if let ls = NSKeyedUnarchiver.unarchiveObjectWithData(lsData) as? LocalSettings {
                return ls
            }
        }
        
        return nil
    }
    
    override init() {
        afterAction = .DoNothing
    }
    
    required init(coder aDecoder: NSCoder) {
        afterAction = AfterScreenshotUploadAction(rawValue: aDecoder.decodeIntegerForKey("afterAction"))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(afterAction.rawValue, forKey: "afterAction")
    }
    
    func save() {
        LocalSettings.defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self), forKey: LocalSettings.kLocalSettingsKey)
    }
}
