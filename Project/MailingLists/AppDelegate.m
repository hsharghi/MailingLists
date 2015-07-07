//
//  AppDelegate.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۱۳۹۲/۹/۲۶ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//


#import "AppDelegate.h"
#import <Foundation/NSFileManager.h>
#import <Foundation/NSFileHandle.h>
#import "MediaDirectory.h"
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate()
{
}

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Crashlytics startWithAPIKey:@"cdc7d1cb1a43b59a67b2595b1fa252e92322548a"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    long numberOfLaunches = [ud integerForKey:kNumberOfLaunches];
    
    if (numberOfLaunches == 0)
    {
        [ud setInteger:numberOfLaunches+1 forKey:kNumberOfLaunches];
        [ud setBool:YES forKey:kSoundFX];
        [ud setBool:YES forKey:kShowEditOptionsPopUp];
        [ud setBool:YES forKey:kShowQuickTour];
        [ud synchronize];
    }
    else if (numberOfLaunches < 5)
    {
        [ud setInteger:numberOfLaunches+1 forKey:kNumberOfLaunches];
        [ud setBool:NO forKey:kShowQuickTour];
        [ud synchronize];
    }
    else
    {
        NSString *rated = [ud stringForKey:kAppStoreRate];
        
        if (![rated isEqualToString:kRated]) {
            self.showRateAlert = YES;
        }
        [ud setBool:NO forKey:kShowQuickTour];
        [ud synchronize];
    }
    
    self.playSoundFX = [ud boolForKey:kSoundFX];
    self.showQuickTour = [ud boolForKey:kShowQuickTour];
    self.showEditOptionsPopUp = [ud boolForKey:kShowEditOptionsPopUp];
    self.premiumVersion = ([ud integerForKey:kPremium] == kPremiumIntValue ? YES : NO);

    
//    UIViewControllerBasedStatusBarAppearance = NO;
    
    UIColor *red = [UIColor colorWithRed:209/255.0 green:49/255.0 blue:46/255.0 alpha:1];
//    UIColor *blue = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1];
    UIColor *lightBlue = [UIColor colorWithRed:241/255.0 green:250/255.0 blue:254/255.0 alpha:1];
    
    [[UITableView appearance] setBackgroundColor:lightBlue];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        [[UIToolbar appearance] setBarTintColor:red];
        [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UINavigationBar appearance] setBarTintColor:red];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
        [titleBarAttributes setValue:[UIFont fontWithName:@"HelveticaNeue" size:18] forKey:NSFontAttributeName];
        [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];


    }

    
    NSString *fileStatus = nil;
    
    // Here, the NSFileManager defaultManager fileExistsAtPath method needs a path to
    // the file in the Document directory, to get this path, use the static method from
    // my MediaDirectory class and pass it the name of the file.
    // I called it "fileStatus.txt"
    //
    // We're checking if the file exist in the Documents directory or not.
    // If it does not exist then we create the text file and pass it the
    // value "show again", otherwise we do nothing.
    // (We don't want to overwrite the value everytime the app starts)
    if([[NSFileManager defaultManager] fileExistsAtPath:[MediaDirectory mediaPathForFileName:@"fileStatus.txt"]] == NO)
    {
        // prepare fileStatus.txt by setting "show again" into our string
        // we will write this string into the text file later
        fileStatus = @"show again";
        
        // now we write the value "show again" so that the UIAlertView will show
        // when it checks for the value, until the user clicks on no and we set
        // this value to "don't show again" later in another piece of code
        [fileStatus writeToFile:[MediaDirectory mediaPathForFileName:@"fileStatus.txt"]
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:nil];
        
        [MediaDirectory addSkipBackupAttributeToFile:@"fileStatus.txt"];

    }
   
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        // Fire a notification to let all views know that our app entered foreground.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEnteredForground
                                                            object:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (_showRateAlert)
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppStoreRate
                                                            object:nil];
    
    if (_showQuickTour)
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowQuickTour object:nil];
    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
