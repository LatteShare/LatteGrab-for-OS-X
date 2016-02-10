//
//  RecentItem.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class RecentItem : Serializable {
    
    let id : String
    let date : NSDate
    
    init(identifier: String, dateUploaded: NSDate) {
        id = identifier
        date = dateUploaded
    }
    
}

class RecentItems {
    
    static let kRecentItemsKey = "Recent Items"
    
    var defaults : NSUserDefaults
    
    var recentItems : [RecentItem]
    
    init() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if let r = defaults.objectForKey(kRecentItemsKey) {
            
        } else {
            recentItems = []
        }
    }
    
}