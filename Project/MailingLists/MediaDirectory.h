//
//  MediaDirectory.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۱/۱ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/xattr.h>


@interface MediaDirectory : NSObject

+(NSString *) mediaPathForFileName:(NSString *) fileName;
+(BOOL)addSkipBackupAttributeToFile:(NSString *) fileName;


@end
