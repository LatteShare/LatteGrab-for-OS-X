//
//  StatusBarController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class StatusBarController: NSObject {
    
    @IBOutlet weak var menu : NSMenu!
    @IBOutlet weak var recentFilesMenu : NSMenu!
    
    @IBOutlet weak var recentFilesMenuItem : NSMenuItem?
    
    var statusItem : NSStatusItem!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        statusItem.title = "LG"
        statusItem.menu = menu
        
        recentFilesMenu.addItem(createMenuItemForFile("foo"))
    }
    
    func createMenuItemForFile(url: String) -> NSMenuItem {
        let menuItem = NSMenuItem(title: url, action: nil, keyEquivalent: "")
        
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
