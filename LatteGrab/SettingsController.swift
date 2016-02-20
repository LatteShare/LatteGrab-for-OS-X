//
//  SettingsController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 11/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

class SettingsController: NSObject, NSWindowDelegate {
    
    var defaults : NSUserDefaults!
    
    var localSettings : LocalSettings!
    
    @IBOutlet weak var window : NSWindow!
    
    @IBOutlet weak var openAtLoginButton : NSButton!
    
    @IBOutlet weak var usernameField : NSTextField!
    @IBOutlet weak var groupField : NSTextField!
    @IBOutlet weak var quotaField : NSTextField!
    
    @IBOutlet weak var serverField : NSTextField!
    @IBOutlet weak var apiVersionField : NSTextField!
    
    @IBOutlet weak var doNothingRadioButton : NSButton!
    @IBOutlet weak var moveToTrashRadioButton : NSButton!
    @IBOutlet weak var deleteFromDiskRadioButton : NSButton!
    
    override func awakeFromNib() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            openAtLoginButton.state = NSOnState
        } else {
            openAtLoginButton.state = NSOffState
        }
        
        if let ls = LocalSettings.getSettings() {
            localSettings = ls
        } else {
            localSettings = LocalSettings()
        }
        
        doNothingRadioButton.action = "changedAfterUploadAction:"
        moveToTrashRadioButton.action = "changedAfterUploadAction:"
        deleteFromDiskRadioButton.action = "changedAfterUploadAction:"
        
        switch localSettings.afterAction {
        case .DoNothing:
            doNothingRadioButton.state = NSOnState
        case .MoveToTrash:
            moveToTrashRadioButton.state = NSOnState
        case .DeleteFromDisk:
            deleteFromDiskRadioButton.state = NSOnState
        }
        
        updateRemoteInfo(self)
    }
    
    func windowDidChangeOcclusionState(notification: NSNotification) {
        updateRemoteInfo(self)
    }
    
    @IBAction func toggleOpenAtLogin(sender: NSButton!) {
        if !PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            PALoginItemUtility.addCurrentApplicatonToLoginItems()
            
            openAtLoginButton.state = NSOnState
        } else {
            PALoginItemUtility.removeCurrentApplicatonFromLoginItems()
            
            openAtLoginButton.state = NSOffState
        }
    }
    
    @IBAction func changedAfterUploadAction(sender: NSButton!) {
        if sender == doNothingRadioButton {
            localSettings.afterAction = .DoNothing
        } else if sender == moveToTrashRadioButton {
            localSettings.afterAction = .MoveToTrash
        } else {
            localSettings.afterAction = .DeleteFromDisk
        }
        
        localSettings.save()
    }
    
    func updateRemoteInfo(sender: AnyObject!) {
        do {
            try LatteShare.sharedInstance.getConnection().getUserInfo({ userInfo in
                let usedReadable = NSByteCountFormatter.stringFromByteCount(userInfo.usedDiskSpace, countStyle: .File)
                let quotaReadable = NSByteCountFormatter.stringFromByteCount(userInfo.quota, countStyle: .File)
                
                self.usernameField.stringValue = userInfo.username
                self.groupField.stringValue = userInfo.group
                self.quotaField.stringValue = "\(usedReadable) / \(userInfo.quota == -1 ? "Unmetered" : quotaReadable)"
                }, failure: { error in
                    print(error)
            })
            
            self.serverField.stringValue = LatteShare.sharedInstance.connectionString
            self.apiVersionField.stringValue = LatteShare.kAPIVersionString
        } catch _ {
            
        }
    }
    
    @IBAction func openGitHub(sender: NSButton!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/LatteShare/LatteGrab-for-OS-X")!)
    }
    
}
