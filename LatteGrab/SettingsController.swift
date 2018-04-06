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
    
    var defaults : UserDefaults!
    
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
        defaults = UserDefaults(suiteName: "io.edr.latteshare.group")!
        
        if PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            openAtLoginButton.state = .on
        } else {
            openAtLoginButton.state = .off
        }
        
        if let ls = LocalSettings.getSettings() {
            localSettings = ls
        } else {
            localSettings = LocalSettings()
        }
        
        doNothingRadioButton.action = #selector(changedAfterUploadAction(sender:))
        moveToTrashRadioButton.action = #selector(changedAfterUploadAction(sender:))
        deleteFromDiskRadioButton.action = #selector(changedAfterUploadAction(sender:))
        
        switch localSettings.afterAction {
        case .DoNothing:
            doNothingRadioButton.state = .on
        case .MoveToTrash:
            moveToTrashRadioButton.state = .on
        case .DeleteFromDisk:
            deleteFromDiskRadioButton.state = .on
        }
        
        updateRemoteInfo(sender: self)
    }
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        updateRemoteInfo(sender: self)
    }
    
    @IBAction func toggleOpenAtLogin(sender: NSButton!) {
        if !PALoginItemUtility.isCurrentApplicatonInLoginItems() {
            PALoginItemUtility.addCurrentApplicatonToLoginItems()
            
            openAtLoginButton.state = .on
        } else {
            PALoginItemUtility.removeCurrentApplicatonFromLoginItems()
            
            openAtLoginButton.state = .off
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
            try LatteShare.sharedInstance.getConnection().getUserInfo(success: { userInfo in
                let usedReadable = ByteCountFormatter.string(fromByteCount: userInfo.usedDiskSpace, countStyle: .file)
                let quotaReadable = ByteCountFormatter.string(fromByteCount: userInfo.quota, countStyle: .file)
                
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
        NSWorkspace.shared.open(URL(string: "https://github.com/LatteShare/LatteGrab-for-OS-X")!)
    }
    
}
