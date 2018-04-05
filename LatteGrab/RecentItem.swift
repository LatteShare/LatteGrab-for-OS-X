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
        id = aDecoder.decodeObject(forKey: "id") as! String
        date = aDecoder.decodeObject(forKey: "date") as! NSDate
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(date, forKey: "date")
    }
    
}

public class RecentItems {
    
    static let kRecentItemsKey = "Recent Items"
    
    private var defaults : UserDefaults
    
    private var recentItems : [RecentItem]
    
    public init() {
        defaults = UserDefaults(suiteName: "io.edr.latteshare.group")!
        
        if let r = defaults.object(forKey: RecentItems.kRecentItemsKey) as? Data {
            if let rec = NSKeyedUnarchiver.unarchiveObject(with: r) as? [RecentItem] {
                recentItems = rec
                
                return
            }
        }
        
        recentItems = []
    }
    
    public func load() {
        defaults = UserDefaults(suiteName: "io.edr.latteshare.group")!
        
        if let r = defaults.object(forKey: RecentItems.kRecentItemsKey) as? Data {
            if let rec = NSKeyedUnarchiver.unarchiveObject(with: r) as? [RecentItem] {
                recentItems = rec
                
                return
            }
        }
        
        recentItems = []
    }
    
    public func save() {
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: recentItems), forKey: RecentItems.kRecentItemsKey)
        
        defaults.synchronize()
    }
    
    public func getRecentItems(maxItems: Int) -> [RecentItem] {
        if maxItems == -1 || maxItems > recentItems.count {
            return recentItems.reversed()
        }
        
        return Array(recentItems.suffix(maxItems)).reversed()
    }
    
    public func addRecentItem(identifier id: String, date: NSDate) {
        recentItems.append(RecentItem(identifier: id, dateUploaded: date))
        
        save()
    }
    
    public func addRecentItem(item: RecentItem) {
        recentItems.append(item)
        
        save()
    }
    
    public func removeRecentItem(item: RecentItem) -> Bool {
        for index in 0 ... recentItems.count - 1 {
            if item.id == recentItems[index].id {
                recentItems.remove(at: index)
                
                save()
                
                return true
            }
        }
        
        return false
    }
}
