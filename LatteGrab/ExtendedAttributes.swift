//
//  Based on https://github.com/okla/swift-xattr
//
//  Cleaned up, migrated to class and Swift 2.0... And then migrated again to Swift 4.0
//

import Foundation

class ExtendedAttributes {
    /** Description of current errno value */
    
    static func errnoDescription() -> String {
        return String(cString: strerror(errno))
    }
    
    /**
     Set extended attribute at path
     
     :param: name Name of extended attribute
     :param: data Data associated with extended attribute
     :param: atPath Path to file, directory, symlink etc
     
     :returns: error description if failed, otherwise nil
     */
    
    static func setAttributeWithName(name: String, data: NSData, atPath path: String) -> String? {
        return setxattr(path, name, data.bytes, data.length, 0, 0) == -1 ? errnoDescription() : nil
    }
    
    /**
     Get data for extended attribute at path
     
     :param: name Name of extended attribute
     :param: atPath Path to file, directory, symlink etc
     
     :returns: Tuple with error description and attribute data. In case of success first parameter is nil, otherwise second.
     */
    
    static func dataForAttributeNamed(name: String, atPath path: String) -> (error: String?, data: NSData?) {
        let bufLength = getxattr(path, name, nil, 0, 0, 0)
        
        if bufLength == -1 {
            return (errnoDescription(), nil)
        } else {
            let buf = malloc(bufLength)
            
            if getxattr(path, name, buf, bufLength, 0, 0) == -1 {
                return (errnoDescription(), nil)
            } else {
                return (nil, NSData(bytes: buf, length: bufLength))
            }
        }
    }
    
    /**
     Get names of extended attributes at path
     
     :param: path Path to file, directory, symlink etc
     
     :returns: Tuple with error description and array of extended attributes names. In case of success first parameter is nil, otherwise second.
     */
    
    static func attributesNamesAtPath(path: String) -> (error: String?, names: [String]?) {
        let bufLength = listxattr(path, nil, 0, 0)
        
        if bufLength == -1 {
            return (errnoDescription(), nil)
        } else {
            let buf = UnsafeMutablePointer<Int8>.allocate(capacity: bufLength)
            
            if listxattr(path, buf, bufLength, 0) == -1 {
                return (errnoDescription(), nil)
            } else {
                if var names = NSString(bytes: buf, length: bufLength,
                                        encoding: String.Encoding.utf8.rawValue)?.components(separatedBy: "\0") {
                        names.removeLast()
                        
                        return (nil, names)
                } else {
                    return ("Unknown error", nil)
                }
            }
        }
    }
    
    /**
     Remove extended attribute at path
     
     :param: name Name of extended attribute
     :param: atPath Path to file, directory, symlink etc
     
     :returns: error description if failed, otherwise nil
     */
    
    static func removeAttributeNamed(name: String, atPath path: String) -> String? {
        return removexattr(path, name, 0) == -1 ? errnoDescription() : nil
    }
}
