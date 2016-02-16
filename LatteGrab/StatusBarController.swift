//
//  StatusBarController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

class StatusBarController: NSObject, ScreenshotWatcherDelegate, AuthenticationChangeDelegate {
    
    @IBOutlet weak var settingsWindow : NSWindow!
    
    @IBOutlet weak var menu : NSMenu!
    @IBOutlet weak var recentFilesMenu : NSMenu!
    
    @IBOutlet weak var loggedInMenuItem : NSMenuItem!
    
    var statusItem : NSStatusItem!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        statusItem.image = NSImage(named: "MenuBarIcon")
        statusItem.menu = menu
        
        refresh()
    }
    
    func refresh() {
        recentFilesMenu.removeAllItems()
        
        let ri = RecentItems()
        
        for item in ri.getRecentItems(maxItems: 5) {
            recentFilesMenu.addItem(createMenuItemForFile(item))
        }
        
        if let u = LatteShare.sharedInstance.username {
            loggedInMenuItem.title = "Connected as \(u)"
        } else {
            loggedInMenuItem.title = "Not logged in..."
        }
    }
    
    func screenshotUploaded() {
        refresh()
    }
    
    func authenticationStateDidChange(loggedIn _: Bool) {
        refresh()
    }
    
    func createMenuItemForFile(item: RecentItem) -> NSMenuItem {
        let df = NSDateFormatter()
        
        df.dateStyle = .MediumStyle
        df.timeStyle = .ShortStyle
        
        let menuItem = NSMenuItem(title: df.stringFromDate(item.date), action: nil, keyEquivalent: "")
        
        let subMenu = NSMenu()
        
        subMenu.addItemWithTitle("Copy URL", action: Selector("copyURLClicked:"), keyEquivalent: "")?.target = self
        subMenu.addItem(NSMenuItem.separatorItem())
        subMenu.addItemWithTitle("Delete", action: Selector("deleteClicked:"), keyEquivalent: "")?.target = self
        
        menuItem.representedObject = item
        menuItem.submenu = subMenu
        
        return menuItem
    }
    
    func copyURLClicked(sender: NSMenuItem) {
        print("Copy URL clicked from \(sender).")
        
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().writeObjects([(sender.parentItem!.representedObject as! RecentItem).id])
    }
    
    func deleteClicked(sender: NSMenuItem) {
        print("Delete clicked from \(sender).")
        
        let ri = sender.parentItem!.representedObject as! RecentItem
        
        let arr = ri.id.characters.split{ $0 == "/" }.map(String.init)
        
        do {
            try LatteShare.sharedInstance.getConnection().deleteFile(arr.last!, success: {
                
                let ris = RecentItems()
                
                ris.removeRecentItem(ri)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.refresh()
                }
                
                }, failure: { error in
                    
                    let alert = NSAlert()
                    
                    alert.messageText = "Error!"
                    alert.informativeText = error
                    
                    alert.runModal()
                    
            })
        } catch let e {
            print("Exception while attempting to delete file! \(e)")
        }
    }
    
    @IBAction func openSettings(sender: NSMenuItem) {
        settingsWindow.makeKeyAndOrderFront(self)
        
        settingsWindow.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
