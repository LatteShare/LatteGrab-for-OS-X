//
//  PALoginItemUtility.h
//  devMod
//
//  Created by Paolo Tagliani on 10/25/14.
//  Copyright (c) 2014 Paolo Tagliani. All rights reserved.
//
//  Stolen from https://github.com/pablosproject/Panda-Mac-app/tree/master/Panda/Library/Login%20Item%20Utility
//

#import <Foundation/Foundation.h>

@interface PALoginItemUtility : NSObject

+ (BOOL)isCurrentApplicatonInLoginItems;
+ (void)addCurrentApplicatonToLoginItems;
+ (void)removeCurrentApplicatonFromLoginItems;

@end
