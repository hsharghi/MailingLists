//
//  SoundEffect.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۳/۲/۱۳ .
//  Copyright (c) ۱۳۹۳ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "SoundEffect.h"

@implementation SoundEffect

- (id)initWithSoundNamed:(NSString *)filename
{
    if ((self = [super init]))
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil)
        {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError)
                _soundID = theSoundID;
        }
    }
    return self;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(_soundID);
}

- (void)play
{
    AudioServicesPlaySystemSound(_soundID);
}

- (void)stop
{
    AudioServicesDisposeSystemSoundID(_soundID);
}


@end
