//
//  StatusBarController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

class StatusBarController: NSObject {
    
    @IBOutlet weak var menu : NSMenu!
    @IBOutlet weak var recentFilesMenu : NSMenu!
    
    @IBOutlet weak var loggedInMenuItem : NSMenuItem!
    
    var statusItem : NSStatusItem!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        statusItem.title = "LG"
        statusItem.menu = menu
        
        refresh()
    }
    
    func refresh() {
        recentFilesMenu.removeAllItems()
        
        let ri = RecentItems()
        
        for item in ri.getRecentItems(maxItems: -1) {
            createMenuItemForFile(item)
        }
        
        if let u = LatteShare.sharedInstance.username {
            loggedInMenuItem.title = "Connected as \(u)"
        } else {
            loggedInMenuItem.title = "Not logged in..."
        }
        
    }
    
    func createMenuItemForFile(item: RecentItem) -> NSMenuItem {
        let menuItem = NSMenuItem(title: item.id, action: nil, keyEquivalent: "")
        
        let subMenu = NSMenu()
        
        subMenu.addItemWithTitle("Copy URL", action: Selector("copyURLClicked:"), keyEquivalent: "")?.target = self
        subMenu.addItem(NSMenuItem.separatorItem())
        subMenu.addItemWithTitle("Delete", action: Selector("deleteClicked:"), keyEquivalent: "")?.target = self
        
        menuItem.submenu = subMenu
        
        return menuItem
    }
    
    func copyURLClicked(sender: NSMenuItem) {
        print("Copy URL clicked from \(sender).")
    }
    
    func deleteClicked(sender: NSMenuItem) {
        print("Delete clicked from \(sender).")
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func openSettings(sender: NSMenuItem) {
        
    }
    
}
