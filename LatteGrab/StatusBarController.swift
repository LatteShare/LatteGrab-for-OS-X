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
    @IBOutlet weak var recentFilesMenuItem : NSMenuItem!
    @IBOutlet weak var settingsMenuItem : NSMenuItem!
    
    var statusItem : NSStatusItem!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
                statusItem.image = NSImage(named: NSImage.Name("MenuBarIcon"))
        statusItem.menu = menu
        
        refresh()
    }
    
    func refresh() {
        recentFilesMenu.removeAllItems()
        
        let ri = RecentItems()
        
        for item in ri.getRecentItems(maxItems: 5) {
            recentFilesMenu.addItem(createMenuItemForFile(item: item))
        }
        
        if let u = LatteShare.sharedInstance.username {
            loggedInMenuItem.title = "Connected as \(u)"
            
            recentFilesMenuItem.isHidden = false
            settingsMenuItem.isHidden = false
        } else {
            loggedInMenuItem.title = "Not logged in..."
            
            recentFilesMenuItem.isHidden = true
            settingsMenuItem.isHidden = true
        }
    }
    
    func screenshotUploaded() {
        refresh()
    }
    
    func authenticationStateDidChange(loggedIn _: Bool) {
        refresh()
    }
    
    func createMenuItemForFile(item: RecentItem) -> NSMenuItem {
        let df = DateFormatter()
        
        df.dateStyle = .medium
        df.timeStyle = .short
        
        let menuItem = NSMenuItem(title: df.string(from: item.date as Date), action: nil, keyEquivalent: "")
        
        let subMenu = NSMenu()
        
        subMenu.addItem(withTitle: "Copy URL", action: #selector(copyURLClicked(sender:)), keyEquivalent: "").target = self
        subMenu.addItem(NSMenuItem.separator())
        subMenu.addItem(withTitle: "Delete", action: #selector(deleteClicked(sender:)), keyEquivalent: "").target = self
        
        menuItem.representedObject = item
        menuItem.submenu = subMenu
        
        return menuItem
    }
    
    @objc func copyURLClicked(sender: NSMenuItem) {
        print("Copy URL clicked from \(sender).")
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([(sender.parent!.representedObject as! RecentItem).id as NSPasteboardWriting])
    }
    
    @objc func deleteClicked(sender: NSMenuItem) {
        print("Delete clicked from \(sender).")
        
        let ri = sender.parent!.representedObject as! RecentItem
        
        let arr = ri.id.split{ $0 == "/" }.map(String.init)
        
        do {
            try LatteShare.sharedInstance.getConnection().deleteFile(fileIdentifier: arr.last!, success: {
                let ris = RecentItems()
                
                let _ = ris.removeRecentItem(item: ri)
                
                DispatchQueue.main.async {
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
        
        settingsWindow.level = .floating
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
