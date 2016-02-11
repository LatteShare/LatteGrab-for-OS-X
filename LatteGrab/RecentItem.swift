//
//  RecentItem.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

public class RecentItem : NSObject, NSCoding {
    
    public let id : String
    public let date : NSDate
    
    init(identifier: String, dateUploaded: NSDate) {
        id = identifier
        date = dateUploaded
    }
    
    required public init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(date, forKey: "date")
    }
    
}

public class RecentItems {
    
    static let kRecentItemsKey = "Recent Items"
    
    private var defaults : NSUserDefaults
    
    private var recentItems : [RecentItem]
    
    public init() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if let r = defaults.objectForKey(RecentItems.kRecentItemsKey) as? NSData {
            if let rec = NSKeyedUnarchiver.unarchiveObjectWithData(r) as? [RecentItem] {
                recentItems = rec
                
                return
            }
        }
        
        recentItems = []
    }
    
    public func load() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if let r = defaults.objectForKey(RecentItems.kRecentItemsKey) as? NSData {
            if let rec = NSKeyedUnarchiver.unarchiveObjectWithData(r) as? [RecentItem] {
                recentItems = rec
                
                return
            }
        }
        
        recentItems = []
    }
    
    public func save() {
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(recentItems), forKey: RecentItems.kRecentItemsKey)
    }
    
    public func getRecentItems(maxItems maxItems: Int) -> [RecentItem] {
        if maxItems == -1 || maxItems > recentItems.count {
            return recentItems
        }
        
        return Array(recentItems.suffix(maxItems))
    }
}
