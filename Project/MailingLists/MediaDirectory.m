//
//  MediaDirectory.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۱/۱ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "MediaDirectory.h"

@implementation MediaDirectory


+ (NSString *) mediaPathForFileName:(NSString *) fileName
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachesDirectory, fileName];
    
    return filePath;
}

+ (BOOL)addSkipBackupAttributeToFile:(NSString *) fileName
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePathStr = [NSString stringWithFormat:@"%@/%@", cachesDirectory, fileName];
    
    const char* filePath = [filePathStr fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


@end

