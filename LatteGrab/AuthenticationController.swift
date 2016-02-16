//
//  AuthenticationController.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

protocol AuthenticationChangeDelegate {
    func authenticationStateDidChange(loggedIn loggedIn: Bool)
}

class AuthenticationController: NSObject {
    
    @IBOutlet weak var window : NSWindow!
    
    @IBOutlet weak var usernameField : NSTextField!
    @IBOutlet weak var passwordField : NSTextField!
    @IBOutlet weak var serverField : NSTextField!
    
    @IBOutlet weak var loginButton : NSButton!
    
    var delegate : AuthenticationChangeDelegate?
    
    override func awakeFromNib() {
        if !LatteShare.sharedInstance.hasAuthenticationDetails() {
            window.makeKeyAndOrderFront(self)
            
            window.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
            
            delegate?.authenticationStateDidChange(loggedIn: false)
        } else {
            delegate?.authenticationStateDidChange(loggedIn: true)
        }
    }
    
    @IBAction func signUp(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://grabpaw.com/signup")!)
    }
    
    @IBAction func logIn(sender: NSButton) {
        if usernameField.stringValue == "" || passwordField.stringValue == "" {
            let alert = NSAlert()
            
            alert.messageText = "Error!"
            alert.informativeText = "Neither of the fields \"Username\" and \"Password\" can be blank."
            
            alert.runModal()
            
            return
        }
        
        loginButton.enabled = false
        
        var connectionString = (serverField.stringValue != "" ? serverField.stringValue : "https://grabpaw.com");
        
        while connectionString.characters.count > 0 && connectionString.characters.last! == "/" {
            connectionString = String(connectionString.characters.dropLast())
        }
        
        let tempConnection = LatteShareConnection(apiEndpoint: LatteShare.generateEndpoint(connectionString))
        
        tempConnection.generateToken(usernameField.stringValue, password: passwordField.stringValue, success: { token in
            
            LatteShare.sharedInstance.connectionString = connectionString
            LatteShare.sharedInstance.username = self.usernameField.stringValue
            LatteShare.sharedInstance.token = token
            
            LatteShare.sharedInstance.newConnection()
            LatteShare.sharedInstance.save()
            
            self.loginButton.enabled = true
            
            self.delegate?.authenticationStateDidChange(loggedIn: true)
            
            self.window.close()
            
        }, failure: { error in
            
            let alert = NSAlert()
            
            alert.messageText = "Error!"
            alert.informativeText = error
            
            alert.runModal()
            
            self.loginButton.enabled = true
            
            self.delegate?.authenticationStateDidChange(loggedIn: false)
            
        })
    }

}
