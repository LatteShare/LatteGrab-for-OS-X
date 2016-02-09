//
//  LatteShareConnection.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 09/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Alamofire
import SwiftyJSON

class LatteShareConnection {
    
    let endpoint: String
    var username: String?
    var token: String?
    
    enum APIError : ErrorType {
        case NotLoggedIn
    }
    
    init(apiEndpoint: String) {
        endpoint = apiEndpoint
    }
    
    init(apiEndpoint: String, apiUsername: String, apiToken: String) {
        endpoint = apiEndpoint
        username = apiUsername
        token = apiToken
    }
    
    func validateToken(validated: Bool -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn
        }
        
        Alamofire.request(.GET, endpoint + "key", parameters: [ "username": username!, "apiKey": token! ]).responseJSON() { response in
            if let value = response.result.value {
                print("JSON: \(value)")
                
                let json = JSON(value)
                
                validated(json["success"].boolValue)
            } else {
                validated(false);
            }
        }
    }
    
    func generateToken(username: String, password: String, success: String -> (), failure: String -> ()) {
        Alamofire.request(.POST, endpoint + "key", parameters: [ "username": username, "password": password ]).responseJSON() { response in
            if let value = response.result.value {
                print("JSON: \(value)")
                
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
                    failure(error.description)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
    
    func uploadFile(filePath: String, success: String -> (), failure: String -> ()) {
        let parameters = [
            "username": username!,
            "apiKey": token!
        ]
        
        Alamofire.upload(.POST, endpoint + "upload", multipartFormData: {
            multipartFormData in
            
            multipartFormData.appendBodyPart(data: NSData(contentsOfFile: filePath)!, name: "upload", fileName: NSURL(fileURLWithPath: filePath).lastPathComponent!, mimeType: "application/octet-stream")
            
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
        }, encodingCompletion: {
            encodingResult in
                
            switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        
                        if let value = response.result.value {
                            print("JSON: \(value)")
                            
                            let json = JSON(value)
                            
                            if json["success"].boolValue == true {
                                success(json["url"].stringValue)
                            } else {
                                failure("Invalid login details.")
                            }
                        } else {
                            if let error = response.result.error {
                                failure(error.description)
                            } else {
                                failure("Unexpected error.")
                            }
                        }
                    }
                
                case .Failure(let encodingError):
                    print(encodingError)
            }
        })
    }
    
    func createGroup(fileIdentifiers: [String], success: String -> (), failure: String -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn;
        }
        
        Alamofire.request(.POST, endpoint + "group", parameters: [ "username": username!, "apiKey": token!, "ids": fileIdentifiers ]).responseJSON() { response in
            if let value = response.result.value {
                print("JSON: \(value)")
                
                let json = JSON(value);
                
                if json["success"].boolValue == true {
                    success(json["url"].stringValue)
                } else {
                    failure(json["message"].stringValue)
                }
            } else {
                if let error = response.result.error {
                    failure(error.description)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
    
    func deleteFile(fileIdentifier: String, success: () -> (), failure: String -> ()) throws {
        if username == nil || token == nil {
            throw APIError.NotLoggedIn;
        }
        
        Alamofire.request(.DELETE, endpoint + "file/" + fileIdentifier, parameters: [ "username": username!, "apiKey": token! ]).responseJSON() { response in
            if let value = response.result.value {
                print("JSON: \(value)")
                
                let json = JSON(value)
                
                if json["success"].boolValue == true {
                    success()
                } else {
                    failure(json["message"].stringValue)
                }
            } else {
                if let error = response.result.error {
                    failure(error.description)
                } else {
                    failure("Unexpected error.")
                }
            }
        }
    }
}
