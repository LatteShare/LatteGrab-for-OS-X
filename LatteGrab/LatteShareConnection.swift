//
//  LatteShareConnection.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Alamofire
import SwiftyJSON

public struct LatteShareUserInformation {
    public let username : String
    public let group : String
    public let quota : Int64
    public let usedDiskSpace : Int64
}

public class LatteShareConnection {
    
    let endpoint: String
    var username: String?
    var token: String?
    
    public enum APIError : Error {
        case NotLoggedIn
    }
    
    public init(apiEndpoint: String) {
        endpoint = apiEndpoint
    }
    
    public init(apiEndpoint: String, apiUsername: String, apiToken: String) {
        endpoint = apiEndpoint
        username = apiUsername
        token = apiToken
    }
    
    public func hasStoredDetails() -> Bool {
        return username != nil && token != nil
    }
    
    public func getUserInfo(success: @escaping (LatteShareUserInformation) -> (), failure: @escaping (String) -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn
        }
        
        Alamofire.request(endpoint + "user", parameters: [ "apiKey": token! ]).responseJSON() { response in
            if let value = response.result.value {
                let json = JSON(value)
                
                if json["success"].boolValue == true {
                    success(LatteShareUserInformation(
                        username: json["data"]["username"].stringValue,
                        group: json["data"]["group"].stringValue,
                        quota: json["data"]["quota"].int64Value,
                        usedDiskSpace: json["data"]["usedDiskSpace"].int64Value)
                    )
                } else {
                    failure(json["error"].stringValue)
                }
            } else {
                failure("Invalid login details.")
            }
        }
    }
    
    public func validateToken(validated: @escaping (Bool) -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn
        }
        
        Alamofire.request(endpoint + "key", parameters: [ "username": username!, "apiKey": token! ]).responseJSON() { response in
            if let value = response.result.value {
                let json = JSON(value)
                
                validated(json["success"].boolValue)
            } else {
                validated(false);
            }
        }
    }
    
    public func generateToken(username: String, password: String, success: @escaping (String) -> (), failure: @escaping  (String) -> ()) {
        Alamofire.request(endpoint + "key", method: .post, parameters: [ "username": username, "password": password ]).responseJSON() { response in
            if let value = response.result.value {
                let json = JSON(value)
                
                if json["success"].boolValue == true {
                    self.username = username
                    self.token = json["key"].stringValue
                    
                    success(self.token!)
                } else {
                    failure("Invalid login details.")
                }
            } else {
                if let error = response.result.error {
                    failure(error.localizedDescription)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
    
    public func uploadFile(filePath: String, success: @escaping (String) -> (), failure: @escaping (String) -> ()) {
        let parameters = [
            "username": username!,
            "apiKey": token!
        ]
        
        Alamofire.upload(multipartFormData: {
            multipartFormData in
            
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, NSURL(fileURLWithPath: filePath).pathExtension! as CFString, nil)?.takeRetainedValue()
            
            var mimeType = "application/octet-stream"
            
            if let mt = UTTypeCopyPreferredTagWithClass(UTI!, kUTTagClassMIMEType)?.takeRetainedValue() {
                mimeType = mt as String
            }
            
            multipartFormData.append(NSData(contentsOfFile: filePath)! as Data, withName: "upload", fileName: NSURL(fileURLWithPath: filePath).lastPathComponent!, mimeType: mimeType)
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: endpoint + "upload", encodingCompletion: {
            encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        if json["success"].boolValue == true {
                            success(json["url"].stringValue)
                        } else {
                            failure("Invalid login details.")
                        }
                    } else {
                        if let error = response.result.error {
                            failure(error.localizedDescription)
                        } else {
                            failure("Unexpected error.")
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    public func createGroup(fileIdentifiers: [String], success: @escaping (String) -> (), failure: @escaping (String) -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn;
        }
        
        Alamofire.request(endpoint + "group", method: .post, parameters: [ "username": username!, "apiKey": token!, "ids": JSON(fileIdentifiers).rawString()! ]).responseJSON() { response in
            if let value = response.result.value {
                let json = JSON(value);
                
                if json["success"].boolValue == true {
                    success(json["url"].stringValue)
                } else {
                    failure(json["message"].stringValue)
                }
            } else {
                if let error = response.result.error {
                    failure(error.localizedDescription)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
    
    public func deleteFile(fileIdentifier: String, success: @escaping () -> (), failure: @escaping (String) -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn;
        }
        
        Alamofire.request(endpoint + "file/" + fileIdentifier, method: .delete, parameters: [ "username": username!, "apiKey": token! ]).responseJSON() { response in
            if let value = response.result.value {
                let json = JSON(value)
                
                if json["success"].boolValue == true {
                    success()
                } else {
                    failure(json["message"].stringValue)
                }
            } else {
                if let error = response.result.error {
                    failure(error.localizedDescription)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
}
