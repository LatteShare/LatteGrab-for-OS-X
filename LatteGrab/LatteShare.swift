//
//  LatteShare.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

public class LatteShare {
    public static let sharedInstance = LatteShare()
    
    static let kAPIEndpointKey = "API Endpoint"
    
    static let kUsernameKey = "Username"
    static let kTokenKey = "API Token"
    
    var connection : LatteShareConnection?
    
    public var apiEndpoint : String
    
    public var username : String?
    public var token : String?
    
    var defaults: NSUserDefaults
    
    private init() {
        defaults = NSUserDefaults(suiteName: "io.edr.LatteGrab.group")!
        
        if let e = defaults.objectForKey(LatteShare.kAPIEndpointKey) as? String {
            apiEndpoint = e
        } else {
            apiEndpoint = "https://grabpaw.com/api/v1/"
        }
        
        if let u = defaults.objectForKey(LatteShare.kUsernameKey) as? String {
            username = u
        }
        
        if let t = defaults.objectForKey(LatteShare.kTokenKey) as? String {
            token = t
        }
    }
    
    public func hasAuthenticationDetails() -> Bool {
        return username != nil && token != nil
    }
    
    public func newConnection() {
        if username == nil || token == nil {
            connection = LatteShareConnection(apiEndpoint: apiEndpoint)
        } else {
            connection = LatteShareConnection(apiEndpoint: apiEndpoint, apiUsername: username!, apiToken: token!)
        }
    }
    
    public func getConnection() -> LatteShareConnection? {
        if connection == nil {
            newConnection()
        }
        
        return connection
    }
    
    public func save() {
        defaults.setObject(apiEndpoint, forKey: LatteShare.kAPIEndpointKey)
        defaults.setObject(username, forKey: LatteShare.kUsernameKey)
        defaults.setObject(token, forKey: LatteShare.kTokenKey)
        
        defaults.synchronize()
    }
}
