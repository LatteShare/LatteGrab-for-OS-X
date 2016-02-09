//
//  LatteShare.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

class LatteShare {
    static let sharedInstance = LatteShare()
    
    static let kAPIEndpointKey = "API Endpoint"
    
    static let kUsernameKey = "Username"
    static let kTokenKey = "API Token"
    
    var connection : LatteShareConnection?
    
    var apiEndpoint : String
    
    var username : String?
    var token : String?
    
    private init() {
        if let e = NSUserDefaults.standardUserDefaults().objectForKey(LatteShare.kAPIEndpointKey) as? String {
            apiEndpoint = e
        } else {
            apiEndpoint = "https://grabpaw.com/api/v1/"
        }
        
        if let u = NSUserDefaults.standardUserDefaults().objectForKey(LatteShare.kUsernameKey) as? String {
            username = u
        }
        
        if let t = NSUserDefaults.standardUserDefaults().objectForKey(LatteShare.kTokenKey) as? String {
            token = t
        }
    }
    
    func getConnection() -> LatteShareConnection? {
        if connection == nil {
            if username == nil || token == nil {
                connection = LatteShareConnection(apiEndpoint: apiEndpoint)
            } else {
                connection = LatteShareConnection(apiEndpoint: apiEndpoint, apiUsername: username!, apiToken: token!)
            }
        }
        
        return connection
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().setObject(apiEndpoint, forKey: LatteShare.kAPIEndpointKey)
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: LatteShare.kUsernameKey)
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: LatteShare.kTokenKey)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
