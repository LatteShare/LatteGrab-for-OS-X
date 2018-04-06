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
    
    private static let kServerConnectionStringKey = "Server Connection String"
    
    private static let kUsernameKey = "Username"
    private static let kTokenKey = "API Token"
    
    private static let kDefaultServer = "https://grabpaw.com"
    
    public static let kAPIVersionString = "v1"
    
    private var connection : LatteShareConnection?
    
    public var connectionString : String
    
    public var apiEndpoint : String {
        get {
            return LatteShare.generateEndpoint(server: connectionString)
        }
    }
    
    public var username : String?
    public var token : String?
    
    public static func generateEndpoint(server: String) -> String {
        return server + "/api/" + LatteShare.kAPIVersionString + "/"
    }
    
    var defaults: UserDefaults
    
    private init() {
        defaults = UserDefaults(suiteName: "3D7R27DBRZ.group.io.edr.lattegrab")!
        
        if let e = defaults.object(forKey: LatteShare.kServerConnectionStringKey) as? String {
            connectionString = e
        } else {
            connectionString = LatteShare.kDefaultServer
        }
        
        if let u = defaults.object(forKey: LatteShare.kUsernameKey) as? String {
            username = u
        }
        
        if let t = defaults.object(forKey: LatteShare.kTokenKey) as? String {
            token = t
        }
    }
    
    public func setServer(connectionString cs: String) {
        connectionString = cs
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
    
    public func getConnection() -> LatteShareConnection {
        if connection == nil {
            newConnection()
        }
        
        return connection!
    }
    
    public func save() {
        defaults.set(connectionString, forKey: LatteShare.kServerConnectionStringKey)
        defaults.set(username, forKey: LatteShare.kUsernameKey)
        defaults.set(token, forKey: LatteShare.kTokenKey)
        
        defaults.synchronize()
    }
}
