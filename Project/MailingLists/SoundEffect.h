//
//  SoundEffect.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۲/۱۳ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffect : NSObject
{
//    SystemSoundID soundID;
}

@property (readonly, nonatomic) SystemSoundID soundID;
- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;
- (void)stop;


@end
