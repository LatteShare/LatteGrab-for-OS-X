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
    
    static var defaults: UserDefaults = UserDefaults.standard
    
    var afterAction : AfterScreenshotUploadAction
    
    enum AfterScreenshotUploadAction : Int {
        case DoNothing
        case MoveToTrash
        case DeleteFromDisk
    }
    
    static func getSettings() -> LocalSettings? {
        if let lsData = defaults.object(forKey: kLocalSettingsKey) as? Data {
            if let ls = NSKeyedUnarchiver.unarchiveObject(with: lsData) as? LocalSettings {
                return ls
            }
        }
        
        return nil
    }
    
    override init() {
        afterAction = .DoNothing
    }
    
    required init(coder aDecoder: NSCoder) {
        afterAction = AfterScreenshotUploadAction(rawValue: aDecoder.decodeInteger(forKey: "afterAction"))!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(afterAction.rawValue, forKey: "afterAction")
    }
    
    func save() {
        LocalSettings.defaults.set(NSKeyedArchiver.archivedData(withRootObject: self), forKey: LocalSettings.kLocalSettingsKey)
    }
}
